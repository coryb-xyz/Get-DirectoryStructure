# Get-DirectoryStructure

## Overview

The `Get-DirectoryStructure` cmdlet is designed to recursively retrieve and display the directory structure of one or more specified paths. It provides a hierarchical view of directories and files, making it easier to understand the organization of your file system.

## Parameters

### -Path

Specifies one or more paths for which to retrieve the directory structure. The default is the current working directory.

**Aliases:** `FullName`

**Example:**

```powershell
Get-DirectoryStructure -Path C:\Projects
```

## Examples

### Example 1: Retrieve Directory Structure of a Single Path

```powershell
Get-DirectoryStructure -Path C:\Projects
```

**Output:**

```plaintext
└── C:\
    └── Projects\
        ├── bin\
        │   ├── Debug\
        │   └── Release\
        ├── obj\
        │   ├── Debug\
        │   └── Release\
        ├── Properties\
        │   └── AssemblyInfo.cs
        ├── Program.cs
        └── README.md
```

### Example 2: Retrieve Directory Structures of Multiple Paths

```powershell
Get-DirectoryStructure -Path C:\Projects, D:\Documents
```

**Output:**

```plaintext
└── C:\
    └── Projects\
        ├── bin\
        │   ├── Debug\
        │   └── Release\
        ├── obj\
        │   ├── Debug\
        │   └── Release\
        ├── Properties\
        │   └── AssemblyInfo.cs
        ├── Program.cs
        └── README.md

└── D:\
    └── Documents\
        └── Work\
            ├── Project1\
            │   ├── src\
            │   │   └── main.cpp
            │   └── docs\
            │       └── README.txt
            └── Project2\
                ├── data\
                │   └── config.json
                └── scripts\
                    └── script.py
```

## Notes

- This cmdlet uses a recursive approach to build the directory structure.
- It handles case-insensitive comparisons for directories.
- The output is indented to clearly show the hierarchical relationship between directories and files.