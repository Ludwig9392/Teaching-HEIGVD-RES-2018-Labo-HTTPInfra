# Teaching-HEIGVD-RES-2018-Labo-HTTPInfra

> Teacher   : Olivier Liechti  
> Assistant : Miguel Santamaria  
> Date      : 15 juin 2018  
> Students  : Frueh Loïc and Muaremi Dejvid  

____

[TOC]

____

## Objectives  

The first objective of this lab is to get familiar with software tools that will allow us to build a **complete web infrastructure**. By that, we mean that we will build an environment that will allow us to serve **static and dynamic content** to web browsers. To do that, we will see that the **apache httpd server** can act both as a **HTTP server** and as a **reverse proxy**. We will also see that **express.js** is a JavaScript framework that makes it very easy to write dynamic web apps.  

The second objective is to implement a simple, yet complete, **dynamic web application**. We will create **HTML**, **CSS** and **JavaScript** assets that will be served to the browsers and presented to the users. The JavaScript code executed in the browser will issue asynchronous HTTP requests to our web infrastructure (**AJAX requests**) and fetch content generated dynamically.  

The third objective is to practice our usage of **Docker**. All the components of the web infrastructure will be packaged in custom Docker images (we will create at least 3 different images).  

## Step 1: Static HTTP server with apache httpd

For this first easy step, we had to follow the instructions on the webcast to create our GitHub repo with the first files and branch of the lab.
For this step we will work on the master branch, we decided to create a feature branch only for the bonuses.  
The Objectives of this step is to install and manage a httpd apache server and add it to a docker container, then we have to add our HTML website.
To do so, we went on [Docker Hub : apache image ](https://hub.docker.com/_/php/), as told in the webcast. Ten we made a Dockerfile to build this image.

``` bash
FROM php:7.0-apache
COPY src/ /var/www/html/
```

As you can see, we create a simple apache image and we copy our [bootstrap website](https://startbootstrap.com/template-overviews/stylish-portfolio/) inside. It looks really nice and it's responsive, but it's too simple. We will add a cool feature later to make it even better.

Now that we have set everything, we want to try it, to do so we run the following command on the terminal.

```bash
docker build -t res/apache-php ./docker-images/apache-php-image/
docker run -d res/apache-php
```

We can check that the container is running by launching the command `docker ps` and check that it contains our web app whit the commands `docker exec -it <container> /bin/bash` that will launch a bash on the container to let us see what's inside.  
After that, we can use our browser to look at our website by going to http://dockerIp:80/.  
It's beautiful.


## Step 2: Dynamic HTTP server with express.js

On this step, we have to create a dynamic web app that will generate a list of funny peoples, it's like the one on the webcast but it's a lot better.  
To do so, we decided to make a NodeJS app. But why did we choose to make a NodeJS app you ask ?  
It's because now that we've learn how to make some nice little apps with NodeJS and because we like it a lot (and it's mainly because that's how it's done in the webcast...).
So we added the module [chance](https://chancejs.com/). This node package is really useful when we need some random data to test our app like here and it's possible to make a lot of things with it, and Express to our repository, and made our personnal funny peoples.  

```JavaScript
var Chance = require('chance');
var chance = new Chance();

var Express = require('express');
var app = Express();

app.get('/', function(req, res) {
    res.send(generateFunnyPeople());
});

app.listen(3000, function() {
    console.log('Accepting HTTP requests on port 3000!');
});

function generateFunnyPeople(){
	var numberOfPeople = chance.integer({
		min : 1,
		max : 10
	});

	console.log(numberOfPeople);

	var peoples = [];

	for(var i = 0; i < numberOfPeople; ++i){
        var gender = chance.gender();
		peoples.push({

            'first'   : chance.first({ gender: gender }),
            'last'    : chance.last(),
            'gender'  : gender,
            'country' : chance.country({ full: true }),
            'profession' : chance.profession({rank: true}),
            'company' : chance.company(),
            'email' : chance.email(),
            'pet' : chance.animal(),
		});
	}
	console.log(peoples);
	return peoples;
}
```

This code will generate peoples with their name and profession, and other stuff and of course the most important thing, their pet !

Then we create a Dockerfile for our project.  

```bash
FROM node:8

ADD src /opt/app

WORKDIR /opt/app

RUN npm install --save chance
RUN npm install --save express

CMD ["node", "/opt/app/index.js"]
```

It's a standard one, there's nothing special about it, we need to install the modules that we use and of course we build and run it and as always to test it.

```bash
docker build -t res/express-js ./docker-images/express-image/
sudo docker run -d res/express-js
```

Then we can admire our amazing web app by going to our browser and open it.

## Step 3: Reverse proxy with apache (static configuration)
Everything is working and we're happy now it's time to make it better by adding a proxy. This will make the access to our host easier, at the end of this step we will have a single ip address for our sites. That wil be useful for the next step, when we will use AJAX who need that the sites are on the same domain name.

Now we want to make a static configuration of it. So we start by getting the ip addresses of the containers with the command `docker inspect <name> | grep -i ipaddress` and we will configure the proxy to work like this :
- if the URL is "/api/peoples" it will redirect us the peoples from the NodeJS.
- if the URL is "/" it will redirect us to the static website.

To make it work we have to update the apache configuration file, so we add a 001-reverse-proxy.conf
```XML
<VirtualHost *:80>
	ServerName demo.res.ch

	ProxyPass "/api/peoples/" "http://172.17.0.3:3000/"
	ProxyPassReverse "/api/peoples/" "http://172.17.0.3:3000/"

	ProxyPass "/" "http://172.17.0.2:80/"
  ProxyPassReverse "/" "http://172.17.0.2:80/"
</VirtualHost>
```

And we update our Dockerfile.  

```bash
FROM php:7.0-apache

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

After this YOU have to set your hosts file to know how to redirect demo.res.ch to the docker.
The file is :
- windows : C:\WINDOWS\system32\drivers\etc\hosts
- Mac OS : /private/etc/hosts
- Unix like : /etc/hosts

Now it works and we are happy, but why does it work ?
Well, it's quite easy, ProxyPass will make sure that the requests go to the host and ProxyPassReverse will make sure that we get its responses.
Now you can go on your browser and go from one host to the other by tiping :
- http://demo.res.ch : for the static website
- http://demo.res.ch/api/peoples : to get the peoples from the NodeJS.


## Step 4: AJAX requests with JQuery
We were asked to add a text editor on this step so we changed all our Dockerfile to add the following line : `RUN apt-get update && apt-get install -y nano`.
Then we updated the JavaScript file on the apache host to add a function to read our JSON.
```JavaScript
$(function() {
    console.log("Loading peoples");

    function loadPeoples() {
            $.getJSON( "/api/peoples/", function( peoples ) {
                    console.log(peoples);
                    var name = "No one's here";
                    var gender = "No one's here";
                    var nationality = "No one's here";
                    var job = "No one's here";
                    var pet = "No one's here";
                    if( peoples.length > 0 ) {
                            name = peoples[0].first + " " + peoples[0].last;
                            gender = peoples[0].gender;
                            nationality = peoples[0].country;
                            job = peoples[0].profession + " - " + peoples[0].company;
                            pet = peoples[0].pet;
                    }
                    $(".name").text(name);
                    $(".gender").text(gender);
                    $(".nation").text(nationality);
                    $(".job").text(job);
                    $(".pet").text(pet);
            });
    };

    loadPeoples();
    setInterval( loadPeoples, 7000 );
});
```
And on the template :
```JavaScript
<script src="js/funny-peoples.js"></script>
```
This will get the first name on the JSON list and show it as a message for 7 seconds to let you read it.

And now we are really happy because our application do what we want it to do !
It's a little dirty because we've had to write the ip address and if they change nothing will work at all. So that's why we will change everything on the last step !

## Step 5: Dynamic reverse proxy configuration
The final step, soon everything will be over.
We learn on the webcast that we can use event variable inside the container with the -e option.
So we update the [foreground file](https://github.com/docker-library/php/blob/master/7.0/stretch/apache/apache2-foreground)

```bash
# Add setup for RES lab

echo "Static app URL: $STATIC_APP"
echo "Dynamic app URL: $DYNAMIC_APP"

php /var/apache2/templates/config-template.php > /etc/apache2/sites-available/001-reverse-proxy.conf
```

Then we create a new configuration file to use a dynamic proxy that will get the ip and port for it.

```
<?php
    $static_app = getenv('STATIC_APP');
    $dynamic_app = getenv('DYNAMIC_APP');
?>  

<VirtualHost *:80>
	ServerName demo.res.ch

	ProxyPass '/api/peoples/' 'http://<?php print "$dynamic_app" ?>/'
	ProxyPassReverse '/api/peoples/' 'http://<?php print "$dynamic_app" ?>/'

	ProxyPass '/' 'http://<?php print "$static_app" ?>/'
    ProxyPassReverse '/' 'http://<?php print "$static_app" ?>/'
</VirtualHost>
```

And finaly we update our Dockerfile to copy these files.
```bash
COPY apache2-foreground /usr/local/bin/
COPY templates /var/apache2/templates
```

Here we have some new function that we haven't used before.
- getenv() Gets the value of an environment variable
- <?php print "$static_app" ?> will print the content of the php variable

## Additional steps to get extra points on top of the "base" grade
### Management UI (0.5 pt)

We really love extra points like this one. We had no idea how to do it and typed it on Google, then we found out about Portainer, we looked what it does and it was perfect for our needs, the best part of it is that it's really easy to use.
To have it, you juste run the following commands :
```bash
docker volume create portainer_data
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```
Then we can manage our docker on a browser on http://dockerIp:9000.

## The end is just the beginning

Now everything should work and we want to try it but there's just a little problem, we don't like to type so many commands, it's boring, take a lot of times, and it's easy to make a mistake. It's the same for you isn't it ?  
So we made a script that will do that for us !  
To test the lab, you just need to **clone this repo**, update your **hosts file** and then you have to go on it's **root** and launch our **setup.sh**.

**Now we have done a good job and deserve to get a decent grade, what do you think ?**
