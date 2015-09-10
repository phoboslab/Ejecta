README
====================

> A JS & Image File Encryption Tool.


This tool use for  protect your js & image file in Ejecta-Project


Theory:

* Use this tool to encrypt the js file with a key.
* The encrypted file has a special header.
* When Ejecta loads  js-file  and finds the code has the special header, Ejecta decode the code.
* Do other things as same as before.
 
My english is very poor , so if there are some wrong words please tell me and I am so sorry for that.



-------------------
Command-line
-------------------
	$ cd Tools
	$ node Encryptor.js  input-file  output-file  HARD-TO-GUESS-KEY

> Encryptor.js must be runned in Ejecta/Tools folder

* Info:
    * input-file : the original js file that waiting for encrypting. **Only Support JS & Image file** .
    * output-file : the new encrypted file's name. It will overwrite the file with the same name.
    * HARD-TO-GUESS-KEY : A string without Breakline. It's used for encryption. All files in one Application must use the same key.

*  HARD-TO-GUESS-KEY could include:
	* Letter ( a-z , A-Z )
	* Number ( 0 - 9 )
	* ~ @ # $ % ^ * _ - + =  
	* Double-byte characters (e.g. Chinese , Japanese)

-------------------
Example
-------------------

Run the command in terminal:

Goto App/example/encryption/ Folder, then

	$ node ../../../Tools/Encryptor.js  test-log.js  encrypted-test-log.js Your_123_Key


Then in Ejecta :

	// init Decryptor.
	var decryptor = new Ejecta.DecryptorXOR();
	decryptor.enable();

    ejecta.include("example/encryption/encrypted-test-log.js");


Yes, there is no different from before.



-------------------
NOTE
-------------------

This tool will CHANGE the "```Extension/EJBindingDecryptorXOR.h```" file.
Because the secret-key must be written into the "EJBindingDecryptorXOR.h".

Encryptor.js  & EJBindingDecryptorXOR.m are just  default  encode/decode tools, you can implement your own ones.

And 

NO Perfect Encryption Tool on the earth , So ... :p


(over)
