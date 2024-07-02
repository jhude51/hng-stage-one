## **Introduction**
This article explains a bash script ([GitHub Repo](https://github.com/jhude51/hng-stage-one.git)) designed to automate Linux user account creation from a text file containing the said users, as well as a list of supplementary group(s). The script should create users and groups as specified in the prerequisites section, set up home directories with appropriate permissions and ownership, generate random passwords for the users, and log all actions in a file. In addition, the script should store the generated passwords securely in a text file.

## **Prerequisites**
Before proceeding with this article, it’s pertinent that you have some basic knowledge of **Linux OS** and its commands. Although I have added clear comments to the script, a basic knowledge of Bash scripting is still required to follow along.

To run or use the script, take note of the following:
- Ensure you have sudo privileges as user and group management typically requires root access i.e. run the script with sudo or as root. 
- The script is written for an Ubuntu distro but would still work for other Linux flavors.
- Each line in the text file to be passed to the script as an argument must be formatted as `user; list of groups separated by commas`.
**Sample file structure:**
```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data

```

## **Script Explanation**
With the housekeeping out of the way, below is the breakdown of the script.
### **Validation of Input File**
The script starts by checking that an input file is passed as an argument to the script and the path of the said file is valid (the file exists). 
For both checks, I used the if conditional in combination with the logical AND operator ‘**&&**’, which only evaluates the second statement **if and only if the first statement is true**. If the first statement evaluates to true, the script exits immediately i.e. **_exit 1_**.
![Validation of Input File](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/bd9jh4zdaz9rsjn7r8ei.png)
### **Helper Functions**
Two helper functions are defined for random password generation and logging. The random password generator function – _**password_gen()**_ uses the bash built-in **$RANDOM** variable which by default, generates random integer. The **$RANDOM** variable is piped to the **base64** module to generate an alphanumeric password.
![Helper Functions - Random Password Generator](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/e9zczdq6dm2j1fkas7ne.png)
The logging function – _**logger()**_ when called with an argument, would echo the current date and time together with the action to a file declared as **$LOG_FILE**.
![Helper Functions - Logging Function](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/tbwomr96hpojmkna4t68.png)
### **Secure the Password File**
The directory _**/var/secure**_ is created if it does not exist and only the user has permissions on the directory.
![Secure the Password File](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/p52jtfnssv6edanavocu.png)
### **Working with the Input File**
The input file is first read line by line (**$lines**) and each line (**$line** – delimited by a newline character) is iterated over in a for loop. 
![Working with the Input File - read line](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yhgpmr8vlu3rity34nkv.png)
The **$line** is then split to an array at the delimiter **‘;’** with a trailing whitespace **(‘; ’)**. Remember that each line of the input file is formatted as so - `user; list of groups`. The first slice (string before the field separator/delimiter **‘; ’**) is assigned to the **$username** variable and the other slice to the **$groups** variable.
![Working with the Input File - split username and group](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/atw97pxe8omyojj3qqko.png)
### **User Creation**
The script then checks if a user with the **$username** already exists and if true, skips to the next iteration. Otherwise, the helper _**password_gen()**_ function is called and the value assigned to a **$password** variable. The **useradd** utility is then called with the following flags _m_, _U_ and _G_ (see the useradd man pages) to create the user.  
![User Creation - useradd](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wq49214ymzvjgjfyi3ah.png)
For the user password, we use **chpasswd** utility to set the password with the **$password** generated. In addition, the password is then redirected to the **$PASSWORD_FILE** and appropriate permissions set on the file (only the user has permissions - _rw_).
![User Creation - chpasswd](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/gsatzdwtz6z2xr36y0mu.png)
### **Securing the User Home Directory**
Finally, appropriate permissions are set on the user’s home directory so that only the user has _read,write_ and _execute_ permissions on the directory. 
![Securing the User Home Directory](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/alta5pkyfzdza2rjqwmj.png)

## **Running the Script**
- Make the script executable: `chmod +x /path/to/script`. You might have to run this command as **sudo**
- Run the script with the input file as an argument: `sudo ./path/to/script /path/to/inputfile.txt`.
- You can verify the script ran successfully by running the following:

```
# View the $LOG_FILE
sudo cat /var/log/user_management.log
# View the $PASSWORD_FILE
sudo cat /var/secure/user_passwords.txt
# View the system accounts file
sudo cat /etc/passwd
```

## **Conclusion**
As a Sysops/DevOps engineer, automation of user account management using bash scripts can significantly enhance efficiency and accuracy. Take note that the desired result can be achieved using a different logic and structure. For a more streamlined solution, refactoring the main part of the script into smaller functions should be considered.
This task is a part of the **HNG Internship program** that offers a transformative 2-month internship, where the participants can amplify their skills, cultivate networks whilst working on real life projects like this one. You can learn more about the program by visiting the HNG Internship website at [HNG Internship](https://hng.tech/internship). You can also join the **HNG Premium Network** where you can get connected with top techies, collaborate with them, and grow your career. To learn more about the HNG Premium Network, visit [HNG Premium](https://hng.tech/premium).

