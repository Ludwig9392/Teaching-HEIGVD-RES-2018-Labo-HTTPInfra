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

### Acceptance criteria

* You have a GitHub repo with everything needed to build the Docker image.
* You do a demo, where you build the image, run a container and access content from a browser.
* You have used a nice looking web template, different from the one shown in the webcast.
* You are able to explain what you do in the Dockerfile.
* You are able to show where the apache config files are located (in a running container).
* You have documented your configuration in your report.


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

COPY src /opt/app

CMD ["node", "/opt/app/index.js"]
```

It's a standard one, there's nothing special about it and of course we
build and run it and as always to test it.

```bash
docker build -t res/express-js ./docker-images/express-image/
sudo docker run -d res/express-js
```

Then we can admire our amazing web app by going to our browser and open it.

### Acceptance criteria

* You have a GitHub repo with everything needed to build the Docker image.
* You do a demo, where you build the image, run a container and access content from a browser.
* You generate dynamic, random content and return a JSON payload to the client.
* You cannot return the same content as the webcast (you cannot return a list of people).
* You don't have to use express.js; if you want, you can use another JavaScript web framework or event another language.
* You have documented your configuration in your report.


## Step 3: Reverse proxy with apache (static configuration)


### Acceptance criteria

* You have a GitHub repo with everything needed to build the Docker image for the container.
* You do a demo, where you start from an "empty" Docker environment (no container running) and where you start 3 containers: static server, dynamic server and reverse proxy; in the demo, you prove that the routing is done correctly by the reverse proxy.
* You can explain and prove that the static and dynamic servers cannot be reached directly (reverse proxy is a single entry point in the infra).
* You are able to explain why the static configuration is fragile and needs to be improved.
* You have documented your configuration in your report.



## Step 4: AJAX requests with JQuery


### Acceptance criteria

* You have a GitHub repo with everything needed to build the various images.
* You do a complete, end-to-end demonstration: the web page is dynamically updated every few seconds (with the data coming from the dynamic backend).
* You are able to prove that AJAX requests are sent by the browser and you can show the content of th responses.
* You are able to explain why your demo would not work without a reverse proxy (because of a security restriction).
* You have documented your configuration in your report.

## Step 5: Dynamic reverse proxy configuration


### Acceptance criteria

* You have a GitHub repo with everything needed to build the various images.
* You have found a way to replace the static configuration of the reverse proxy (hard-coded IP adresses) with a dynamic configuration.
* You may use the approach presented in the webcast (environment variables and PHP script executed when the reverse proxy container is started), or you may use another approach. The requirement is that you should not have to rebuild the reverse proxy Docker image when the IP addresses of the servers change.
* You are able to do an end-to-end demo with a well-prepared scenario. Make sure that you can demonstrate that everything works fine when the IP addresses change!
* You are able to explain how you have implemented the solution and walk us through the configuration and the code.
* You have documented your configuration in your report.  


## Additional steps to get extra points on top of the "base" grade


### Management UI (0.5 pt)


### Acceptance criteria  

* You develop a web app (e.g. with express.js) that administrators can use to monitor and update your web infrastructure.
* You find a way to control your Docker environment (list containers, start/stop containers, etc.) from the web app. For instance, you use the Dockerode npm module (or another Docker client library, in any of the supported languages).
* You have documented your configuration and your validation procedure in your report.
