using namespace System.Collections.Generic
using namespace System.Text
using namespace System.IO

<#
.SYNOPSIS
Retrieves and displays the directory structure of one or more paths.

.DESCRIPTION
The Get-DirectoryStructure cmdlet recursively retrieves and displays the directory structure of one or more specified paths. It provides a hierarchical view of directories and files, making it easier to understand the organization of your file system.

Example Paths:
C:\Projects\MyProject
D:\Documents\Work

Example Output:
└── C:\
    └── Projects\
        └── MyProject\
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

.PARAMETER Path
Specifies one or more paths for which to retrieve the directory structure. The default is the current working directory.

.EXAMPLE
Get-DirectoryStructure -Path C:\Projects

Retrieves and displays the directory structure of the C:\Projects folder.

.EXAMPLE
Get-DirectoryStructure -Path C:\Projects, D:\Documents

Retrieves and displays the directory structures of both the C:\Projects and D:\Documents folders.

.NOTES
This cmdlet uses a recursive approach to build the directory structure. It handles case-insensitive comparisons for directories and provides a clear, indented output.
#>

function Get-DirectoryStructure {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string[]]$Path = $PWD.Path
    )

    begin {
        # Initialize a list to store the paths and a string builder to build the output.
        $paths = [List[string]]::new()
        $sb = [StringBuilder]::new()

        # Define a helper function to add lines to the output with proper indentation and prefix.
        function Add-StructureLine {
            param (
                [string]$name,
                [string]$indent,
                [bool]$isLast,
                [bool]$isDirectory
            )

            $prefix = if ($isLast) { '└── ' } else { '├── ' }
            [void]$sb.AppendLine("$indent$prefix$name$($isDirectory ? '/' : '')")
        }
    }

    process {
        # Iterate over each path provided as input.
        foreach ($p in $Path) {
            if (Test-Path $p) {
                # Resolve the full path and add it to the list of paths.
                $paths.Add((Resolve-Path $p).Path)
            }
            else {
                # If a path is not found, write a warning message.
                Write-Warning "Path not found: $p"
            }
        }
    }

    end {
        # If no valid paths were provided, write a warning message and return.
        if ($paths.Count -eq 0) {
            Write-Warning "No valid paths provided."
            return
        }

        # Determine the common prefix of all paths to use as the root of the directory structure.
        $commonPrefix = [Path]::GetDirectoryName($paths[0])
        $pathComparer = [StringComparer]::OrdinalIgnoreCase

        # Create a sorted dictionary to store the directory structure, using case-insensitive comparison.
        $tree = [SortedDictionary[string, object]]::new($pathComparer)

        # Iterate over each path and add it to the directory structure.
        foreach ($path in $paths) {
            $relativePath = $path.Substring($commonPrefix.Length).TrimStart([Path]::DirectorySeparatorChar)
            $parts = $relativePath.Split([Path]::DirectorySeparatorChar)
            $currentLevel = $tree

            for ($i = 0; $i -lt $parts.Length; $i++) {
                $part = $parts[$i]
                $isLast = ($i -eq $parts.Length - 1)

                # If the current part is not already in the dictionary, add it with a new sorted dictionary for its children.
                if (-not $currentLevel.ContainsKey($part)) {
                    $currentLevel[$part] = @{
                        'Children'    = [SortedDictionary[string, object]]::new($pathComparer)
                        'IsDirectory' = -not $isLast -or (Test-Path -Path $path -PathType Container)
                    }
                }

                # If this is the last part of the path, break out of the loop.
                if ($isLast) { break }
                $currentLevel = $currentLevel[$part]['Children']
            }
        }

        # Define a helper function to recursively build the output from the directory structure.
        function Build-Output {
            param (
                $node,
                $indent = ''
            )

            for ($i = 0; $i -lt $keys.Count; $i++) {
                $key = $keys[$i]
                $child = $node[$key]
                $isLast = ($i -eq $keys.Count - 1)

                # Add a line to the output with the current part's name, indentation, and prefix.
                Add-StructureLine -name $key -indent $indent -isLast $isLast -isDirectory $child['IsDirectory']

                # If this part has children, recursively build the output for them.
                if ($child['Children'].Count -gt 0) {
                    $newIndent = $indent + $(if ($isLast) { '    ' } else { '│   ' })
                    Build-Output -node $child['Children'] -indent $newIndent
                }
            }
        }

        # Call the helper function to build the output from the directory structure.
        Build-Output -node $tree

        # Return the final output as a string, trimming any trailing whitespace.
        $sb.ToString().TrimEnd()
    }
}