<?php
$c = new mysqli("localhost","appuser","naaz@123","appdb");
echo "<h2>Student Records (Server: " . gethostname() . ")</h2><table border=1 cellpadding=6>";
echo "<tr><th>ID</th><th>Name</th><th>Course</th></tr>";
$r = $c->query("SELECT * FROM students");
while($row = $r->fetch_assoc()){
  echo "<tr><td>{$row['id']}</td><td>{$row['name']}</td><td>{$row['course']}</td></tr>";
}
echo "</table>";
?>
