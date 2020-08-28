Copying Files Between Local Computer and Instance (AWS):
To copy files between your computer and your instance you can use an FTP service like FileZilla or the command scp which stands for secure copy.
To use scp with a key pair use the following command: 
scp -i path/to/key file/to/copy user@ec2-xx-xx-xxx-xxx.compute-1.amazonaws.com:path/to/file.

To use it without a key pair, just omit the flag -i and type in the password of the user when prompted.
To copy an entire directory, add the -r recursive option: 
scp -i path/to/key -r directory/to/copy user@ec2-xx-xx-xxx-xxx.compute-1.amazonaws.com:path/to/directory.

To copy an entire directory, add the -r recursive option: 
scp -i path/to/key user@ec2-xx-xx-xxx-xxx.compute-1.amazonaws.com:path/to/directory directory/to/copy.








This space is consumed by mail notifications

you can check it by typing

sudo find / -type f -size +1000M -exec ls -lh {} \;
It will show large folders above 1000MB

Result will have a folder

/var/mail/username
You can free that space by running the following command

> /var/mail/username
Note that greater than (>) symbol is not a prompt, you have to run the cmd with it.

Now check you space free space by

df -h
Now you have enough free space, Enjoy... :)

share  improve this answer  follow 
