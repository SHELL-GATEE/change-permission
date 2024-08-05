#!/bin/bash
directory='public_html'
current_user=$(whoami)
auto_mode=false
file_provided=true
extensions=()
user=""
user_set=false
user_option_found=false

# Check if program is running as cron job
if [[ -n "$CRON" ]]; then
    auto_mode=true
fi

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then  #  Help 
    echo "#############################################################"
    echo "Description: Chamge Permission For Files Under 'public_html'"
    echo "Usage: $0 -f <ext_file> [..Options..]"
    echo ""
    echo " -f <ext_file> | to pass file that hold desired extensions to program"
    echo " -a     | to change permissions without prompt"
    echo " -u <username> |search on specific user"
    echo ""
    echo "#############################################################"
    exit 0
fi




# search in arguments
for arg in "$@"; do  # Loop through all arguments
    if [[ "$arg" == "-u" ]]; then 
        user_option_found=true
    fi       
done


if [[ "$user_option_found"==false ]] && [[ "$current_user" == "root" ]]; then
    echo $user_option_found
    echo $current_user
    echo "ERROR: program cannot be run as root!"
    echo "specify option '-u <username>' "
    exit 0
fi
# Parse command-line arguments using getopts
while getopts ":f:au:" opt; do
    case ${opt} in
        a)
            auto_mode=true
            ;;
        u)
            user_set=true
            user="$OPTARG"
            ;;
        f)
            file_provided=true
            extension_list_file="$OPTARG"
            ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            echo "Type "$0 -h or --help" to know how to use program"
            exit 1
            ;;
    esac
done

if [ $user!=root ]; 

then
   echo $user
   exit 0
fi   



#Check a file is provided and exists
if [[ $file_provided == "true" ]]; then
    if [[ ! -f "$extension_list_file" ]]; then
        echo "Error: list file '$extension_list_file' not found." >&2
        exit 1
    fi
    extensions=() # Clear the default white_listed array
    mapfile -t extensions < "$extension_list_file"  # Read lines into the array
fi




# Check if 'public_html' exists 
if [[ $user_set="true" ]] ; then 
    
    if ! find /home/$user -type d -name "$directory" | grep -q .; then
        echo "Error: Directory '$directory' not found anywhere under /home/$user." >&2
        exit 1
    fi
    
    public_dirs=$(find /home/$user -type d -name "$directory")

else

    if ! find /home -type d -name "$directory" | grep -q .; then
        echo "Error: Directory '$directory' not found anywhere under /home." >&2
        exit 1
    fi

    public_dirs=$(find /home -type d -name "$directory")

fi
############################################################################################



# Loop through each found public_html directory
for dir in $public_dirs; do
    owner=$(stat -c '%U' "$dir")  # know the owner of public_html
    owner_home=$(eval echo ~"$owner") # know home dir for that owner
    # Loop through each extension in the array

    for ext in "${extensions[@]}"; do
     if [ "$owner_home" == "$HOME" ] || [ "$current_user" == "root" ]; then
     
        # Find all files with the current extension in the current public_html directory
        files=$(find "$dir" -depth -type f -name "*$ext")
        # Loop through each found file with the current extension

        for file in $files; do
           if [[ -f "$file" ]] && [[ $(stat -c '%A' "$file" | cut -c 5) == '-' ]] && [[ $(stat -c '%A' "$file" | cut -c 8) == '-' ]]; then
              continue
           fi
           if $auto_mode; then
            chmod go-r "$file"
           else 
            read -p "Change Permission of $file? [yes/y]" choice
            case "$choice" in
            [yY]|[yY][eE][sS])
            # Change permissions to remove read AND write permissions for group and others
            chmod go-r "$file"
            # Optionally, print a message for each file
            echo "Remove read permission fpr group & others on: $file"
            ;;
            esac
           fi 
        done
      fi   
    done
done
