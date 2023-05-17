# **Build & Run**

To build the docker image, execute docker build command as you would for any other docker based project

`docker build -t <ImageName:TagName> .`

This builds up the auto-generated function code along with Azure Functions runtime which can then be run using

`docker run -p 8080:80 <ImageName:TagName>`

Now you can go to http://localhost:8080/ in your browser and see your function running.
