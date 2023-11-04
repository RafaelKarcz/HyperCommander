#!/usr/bin/env bash

# Menu windows
menu_window() {

  echo -ne "
------------------------------
| Hyper Commander            |
| 0: Exit                    |
| 1: OS info                 |
| 2: User info               |
| 3: File and Dir operations |
| 4: Find Executables        |
------------------------------
> "
}

sub_menu_window() {

  echo -ne "
---------------------------------------------------
| 0 Main menu | 'up' To parent | 'name' To select |
---------------------------------------------------
> "
}

file_options_window() {

  echo -ne "
---------------------------------------------------------------------
| 0 Back | 1 Delete | 2 Rename | 3 Make writable | 4 Make read-only |
---------------------------------------------------------------------
> "
}

# List files and directories
list_files_directories() {

  echo -e "\nThe list of files and directories:"

  arr=(*)

  for item in "${arr[@]}"; do
    if [[ -f "$item" ]]; then
      echo "F $item"
    elif [[ -d "$item" ]]; then
      echo "D $item"
    fi
  done
}

# Main script logic
echo -e "Hello $USER!\n"

current_menu="main"
selected_file=""

while true; do

  case $current_menu in
    "main")
      menu_window
      read -r answer
      case $answer in
        0) echo -e "\nFarewell!\n"; exit 0 ;;
        1) uname --operating-system --nodename ;;
        2) whoami ;;
        3) current_menu="sub" ;;
        4)
          echo -ne "\nEnter an executable name:\n> "
          read -r executable

          if [[ -z "$executable" ]]; then
            echo -e "\nNo executable name entered. Please try again."
            continue
          fi

          path_to_executable=$(which "$executable" 2>/dev/null)
          if [[ -n "$path_to_executable" ]]; then
            echo -e "\nLocated in:\n$path_to_executable"
            echo -ne "\nEnter arguments (if any):\n> "
            read -r arguments

            if ! "$executable" "$arguments"; then
              echo -e "\nError: Failed to execute '$executable' with arguments '$arguments'.\n"
            fi
          else
            echo -e "\nThe executable with that name does not exist!\n"
          fi
          ;;
        *) echo -e "\nInvalid option!" ;;
      esac
      ;;

    "sub")
      list_files_directories
      sub_menu_window
      read -r answer
      case $answer in
        0) current_menu="main" ;;
        'up') 
          if ! cd ..; then
            echo -e "\nFailed to go up a directory\n"
          fi
          ;;
        *)
          if [[ -d "$answer" ]]; then
            if ! cd "$answer"; then
              echo "Failed to change to directory $answer."
            fi
          elif [[ -f "$answer" ]]; then
            selected_file="$answer"
            current_menu="file_options"
          else
            echo -e "\nInvalid input!\n"
          fi
          ;;
      esac
      ;;

    "file_options")
      file_options_window
      read -r answer
      case $answer in
        0) current_menu="sub" ;;
        1)
          if rm "$selected_file"; then
            echo -e "\n$selected_file has been deleted.\n"
          else
            echo -e "\nFailed to delete $selected_file.\n"
          fi
          current_menu="sub"
          ;;
        2)
          echo -ne "\nEnter the new file name:\n> "
          read -r new_file_name
          if mv "$selected_file" "$new_file_name"; then
            echo -e "\n$selected_file has been renamed as $new_file_name\n"
          else
            echo -e "\nFailed to rename $selected_file.\n"
          fi
          current_menu="sub"
          ;;
        3)
          if chmod a=r+w "$selected_file"; then
            echo -e "\nPermissions have been updated.\n"
            ls -l "$selected_file"
          else
            echo -e "\nFailed to update permissions for $selected_file.\n"
          fi
          current_menu="sub"
          ;;
        4)
          if chmod 664 "$selected_file"; then
            echo -e "\nPermissions have been updated.\n"
            ls -l "$selected_file"
          else
            echo -e "\nFailed to update permission for $selected_file.\n"
          fi
          current_menu="sub"
          ;;
        *) echo -e "\nInvalid option!" ;;
      esac
      ;;
  esac
done
