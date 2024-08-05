# change-permission

## description
1) 'change-perm.sh' program designed to search for 'extensions' of all files under 'public_html' recursively \
        then change these files read permission for groups and others.
2) There is a file 'extensions.txt'  <= can edited per user needs.
3) 'extensions.txt' is mandantory... means must be provided to program.
4) when 'change-perm.sh' runs => user interactively decides to change perm or skip. (-a for auto-mode)
6) use -h or --help with script to get help menu
7) if script runs by root => better to specify '-u <username>' for user you want the script to runs on


# Usage scenarios

### to change permissions (interactively):
```bash
./change-perm.sh -f extensions.txt  -u username1
```
### to change permissions (auto-mode):
```bash
./scanner.sh a -f extensions.txt  -u username1
```

# best practice:

1) sepcify extensions in 'extensions.txt' file.
2) add the script to cronjobs to run periodically.
