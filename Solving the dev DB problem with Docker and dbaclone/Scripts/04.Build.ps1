# Setting environment varibles
$msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"

$projectFile = "C:\Users\sstad\source\repos\Databases\StackOverflow2013\StackOverflow2013-Tests\StackOverflow2013-Tests.sqlproj"

# Running build
.  $msbuildPath $projectFile

