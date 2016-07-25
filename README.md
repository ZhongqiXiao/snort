# Docker container: Snort in Ubuntu 16.04 with Barnyard2, PulledPork and Snorby
A simple snort container inspired from this tutorial :

http://www.ubuntu-howtodoit.com/?p=138


<h2>Building the Snort Docker Image</h2>

Clone the git repo and cd into the "root" directory.

<pre>
  <code>$ git clone https://github.com/amabrouki/snort.git
  $ cd snort</code>
</pre>

Build the container

<pre>
  <code>$ docker build -t snort .</code>
</pre>

<h2>Running the Snort Docker Image</h2>
 To start Snort and set up port forwarding:
<pre>
  <code>$ docker run  --privileged -it -p 3000:3000 -d snort</code>
</pre>

