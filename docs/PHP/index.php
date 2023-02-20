<?php
    // MySQLサーバ接続に必要な値を変数に代入
    $username = 'root';
    $password = 'dmm%WEBCAMP2023';

    // PDO のインスタンスを生成して、MySQLサーバに接続
    $database = new PDO('mysql:host=localhost;dbname=booklist;charset=UTF8;', $username, $password);

    // フォームから書籍タイトルが送信されていればデータベースに保存する
    if (array_key_exists('book_title', $_POST)) {
        // 実行するSQLを作成
        $sql = 'INSERT INTO books (book_title) VALUES(:book_title)';
        // ユーザ入力に依存するSQLを実行するので、セキュリティ対策をする
        $statement = $database->prepare($sql);
        // ユーザ入力データ($_POST['book_title'])をVALUES(?)の?の部分に代入する
        $statement->bindParam(':book_title', $_POST['book_title']);
        // SQL文を実行する
        $statement->execute();
        // ステートメントを破棄する
        $statement = null;
    }

    // 実行するSQLを作成
    $sql = 'SELECT * FROM books ORDER BY created_at DESC';
    // SQLを実行する
    $statement = $database->query($sql);
    // 結果レコード（ステートメントオブジェクト）を配列に変換する
    $records = $statement->fetchAll();

    // ステートメントを破棄する
    $statement = null;
    // MySQLを使った処理が終わると、接続は不要なので切断する
    $database = null;
?>
<!DOCTYPE html>
<html lang="ja">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Booklist</title>
        <link href="https://cdn.jsdelivr.net/npm/daisyui@2.24.0/dist/full.css" rel="stylesheet" type="text/css">
        <script src="https://cdn.tailwindcss.com/3.1.8"></script>
    </head>
    <body class="mt-4">
        <div class="mx-auto w-3/4">
            <h1 class="font-bold text-5xl text-blue-600 my-2"><a href="booklist.php">Booklist</a></h1>
            
            <h2 class="text-4xl my-2">書籍の登録フォーム</h2>
            <form action="index.php" method="POST" class="flex">
                <div class="form-control w-3/4 my-4 flex-1">
                    <!-- フォームの基本 -->
                    <input type="text" name="book_title" required placeholder="書籍タイトルを入力" class="input input-bordered w-3/4 text-xl">
                </div>
                <div class="w-1/4 my-4 flex-1">
                    <button type="submit" name="submit_add_book" class="bg-blue-600 hover:bg-blue-500 text-white rounded px-4 py-2">登録</button>
                </div>
            </form>
            
            <hr />
            
            <h2 class="text-4xl my-2">登録された書籍一覧</h2>
            <ul class="list-disc text-lg ml-16">

<?php
    if ($records) {
        foreach ($records as $record) {
            $book_title = $record['book_title'];
?>
                    <li><?php print htmlspecialchars($book_title, ENT_QUOTES, "UTF-8"); ?></li>
<?php
        }
    }
?>

            </ul>
        </div>
    </body>
</html>