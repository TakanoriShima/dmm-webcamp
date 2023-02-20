FROM amazonlinux:2
LABEL maintainer="infratop" \
        description="Amazon Linux 2 with some development environments"

# install amazon-linux-extras
RUN amazon-linux-extras install -y

# yum update & install
RUN yum update -y \
    && yum install \
        systemd \
        tar \
        curl \
        wget \
        unzip \
        sudo \
        git \
        make \
        openssl \
        penssl-devel \
        gcc-c++ \
        bzip2 \
        readline-devel \
        sqlite-devel \
        passwd \
        ps \
        libpng-devel \
        libjpeg-devel \
        libtiff-devel \
        -y

# setenv
ENV RUBY_VERSION="2.6.3" \
    RAILS_VERSION="5.2.5" \
    NOKOGIRI_VERSION="1.13.10" \
    USERNAME="ec2-user" \
    PASSWORD="password"

# add ec2-user
RUN useradd -m -r -G wheel -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:${PASSWORD}" | chpasswd \
    && echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo \
    && echo "${USERNAME}   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# switch user after login
RUN echo 'su "${USERNAME}"' >> ~/.bashrc

# install aws cli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install

# install node.js
RUN curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash - \
    && sudo yum install -y nodejs

# install php7.4
RUN sudo amazon-linux-extras install -y php7.4 \
    && sudo yum install -y php-mbstring php-xml

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && sudo mv composer.phar /usr/local/bin/composer

# change user
USER ${USERNAME}

# install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
 && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
 && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' | tee -a ~/.bash_profile \
    && echo 'eval "$(rbenv init -)"' | tee -a ~/.bash_profile \
    && echo 'export PATH="/usr/local/bin/aws:$PATH"' | tee -a ~/.bash_profile \
    && source ~/.bash_profile

# install Ruby 2.6.3
ENV PATH $PATH:~/.rbenv/bin
ENV PATH $PATH:~/.rbenv/shims
RUN rbenv install ${RUBY_VERSION}
RUN rbenv global ${RUBY_VERSION}

# install Rails 5.2.5
RUN gem install nokogiri -v ${NOKOGIRI_VERSION}
RUN gem install rails -v ${RAILS_VERSION}

# install SQLite 3.8.11
RUN sudo wget https://kojipkgs.fedoraproject.org//packages/sqlite/3.8.11/1.fc21/x86_64/sqlite-devel-3.8.11-1.fc21.x86_64.rpm \
    && sudo wget https://kojipkgs.fedoraproject.org//packages/sqlite/3.8.11/1.fc21/x86_64/sqlite-3.8.11-1.fc21.x86_64.rpm \
    && sudo yum -y install sqlite-3.8.11-1.fc21.x86_64.rpm sqlite-devel-3.8.11-1.fc21.x86_64.rpm 

# install ImageMagick 7.1.0
RUN cd \
    && git clone https://github.com/ImageMagick/ImageMagick.git ImageMagick-7.0.11 \
    && cd ImageMagick-7.0.11 \
    && ./configure \
    && make \
    && sudo make install

# install MySQL 8.0
RUN sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm 
RUN sudo yum install -y --enablerepo=mysql80-community mysql-community-server 
RUN sudo yum install -y --enablerepo=mysql80-community mysql-community-devel 
RUN sudo touch /var/log/mysqld.log 
RUN sudo systemctl enable mysqld

# install MariaDB 10.5
# RUN sudo amazon-linux-extras install mariadb10.5 \
#     && sudo systemctl enable mariadb.service

# customize bash prompt
COPY prompt.sh /home/${USERNAME}/prompt.sh
RUN sudo chmod 755 /home/${USERNAME}/prompt.sh 
RUN echo 'source ~/prompt.sh' >> /home/${USERNAME}/.bashrc

# git configuration
RUN git config --global push.default simple
RUN git config --global user.name TaroDMM
RUN git config --global user.email dmm@gmail.com

# change directory
WORKDIR /home/${USERNAME}/environment

# copy docs
RUN mkdir docs
COPY docs/ docs/
RUN sudo chmod +x docs/app.sh


# init
USER root
CMD ["/sbin/init"]







