Describe "Get-DirectoryStructure" {
    BeforeAll {
        . $PSScriptRoot/Get-DirectoryStructure.ps1

        # Create a test directory structure
        $null = New-Item -Path "$TestDrive/folder1/subfolder1" -ItemType Directory -Force
        $null = New-Item -Path "$TestDrive/folder1/subfolder2" -ItemType Directory -Force
        $null = New-Item -Path "$TestDrive/folder2" -ItemType Directory -Force
        $null = New-Item -Path "$TestDrive/folder1/file1.txt" -ItemType File
        $null = New-Item -Path "$TestDrive/folder1/subfolder1/file2.txt" -ItemType File
        $null = New-Item -Path "$TestDrive/file3.txt" -ItemType File
    }

    It "Should generate correct structure for the entire test directory" {
        $result = Get-ChildItem $TestDrive -Recurse | Get-DirectoryStructure
        $expected = @"
├── file3.txt
├── folder1/
│   ├── file1.txt
│   ├── subfolder1/
│   │   └── file2.txt
│   └── subfolder2/
└── folder2/
"@
        $result.Trim() | Should -Be $expected.Trim()
    }

    It "Should generate correct structure for a subdirectory" {
        $result = Get-ChildItem "$TestDrive/folder1" -Recurse | Get-DirectoryStructure
        $expected = @"
├── file1.txt
├── subfolder1/
│   └── file2.txt
└── subfolder2/
"@
        $result.Trim() | Should -Be $expected.Trim()
    }

    It "Should handle single file input correctly" {
        $result = Get-Item "$TestDrive/file3.txt" | Get-DirectoryStructure
        $result.Trim() | Should -Be "└── file3.txt"
    }
}