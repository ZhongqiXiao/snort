# Docker container: Snort in Ubuntu 16.04 with Barnyard2, PulledPork and Snorby
Snort in a Docker Container
(Inspired from this tutorial :
http://www.ubuntu-howtodoit.com/?p=138)

<h2>Building the Snort Docker Image</h2>

Clone the git repo and cd into the "root" directory.

<pre>
  <code>$ git clone https://github.com/amabrouki/snort.git
  $ cd snort</code>
</pre>

Build the container

 <div> ! - You need to create an account in https://www.snort.org in order to get an Oinkcode.This will allow you to download the regular rules and documentation. This Oinkcode must be kept safe. Once you have the Oinkcode replace every instance of &lt;oinkcode&gt; in pulledpork.conf with your own Oinkcode 
<br>
<br>
<a href="url">https://snort.org/documents/how-to-find-and-use-your-oinkcode</a>
<br>
<br>
 </div>


<pre>
  <code>$ docker build -t snort .</code>
</pre>

<h2>Running the Snort Docker Image</h2>
 To start Snort and set up port forwarding:
<pre>
  <code>$ docker run  --privileged -it -p 3000:3000 -d snort</code>  
  If you don't know how to redirect traffic to docker interface, this command allow the container a full 
  access to host  network interfaces, but you have to change the name of network interface from run.sh   
  script (eth0 to your name interface)
  <code>$ docker run  --privileged -it --net=host -d snort</code>
  
</pre>

<h2>Passwords</h2>
<div>"Pilote2016" is the password for MYSQL root. </div>
<div>  user : snorby@example.com  password :snorby    for snorby GUI </div>

<br>

<h4>NB:</h4>
 <div> - You should always verify that Snort, barnyard and Snorby is running, with this command "ps -a" </div>
 <div> - You should run the "Snorby Worker" from the GUI (Administaration --> Worker & Job Queue) </div>
 <div> - You sould modify the network addresses you are protecting #ipvar HOME_NET any and the passwords of all components</div>

