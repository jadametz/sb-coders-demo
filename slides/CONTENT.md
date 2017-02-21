# Deploying your Ruby app with Docker

## SB Coders Meetup

- [@jesseadametz](https://twitter.com/jesseadametz)
- [jadametz@invoca.com](mailto:jadametz@invoca.com)
- https://github.com/jadametz

---
class: center, middle, inverse

## What is [Docker](https://www.docker.com) and why should I be using it?

---
.left-column[
  ## What is it?
]
.right-column[
  Docker **containers** wrap a piece of software in a complete filesystem that **contains everything needed to run**: code, runtime, system tools, system libraries – anything that can be installed on a server. This guarantees that the software will **always run the same, regardless of its environment**.
]

---
.left-column[
  ## What is it?
  ## Not a VM
]
.right-column[
  <img src="https://www.docker.com/sites/default/files/WhatIsDocker_2_VMs_0-2_2.png" style="width: 500px; height: 400px">
  Virtual machines include the application, the necessary binaries and libraries, and an entire guest operating system -- **all of which can amount to tens of GBs**.
]

---
.left-column[
  ## What is it?
  ## Not a VM
  ## Containers!
]
.right-column[
  <img src="https://www.docker.com/sites/default/files/WhatIsDocker_3_Containers_2_0.png" style="width: 500px; height: 400px">
  Containers include the application and all of its dependencies --but share the kernel with other containers, running as isolated processes in user space on the host operating system.

  **Docker containers are not tied to any specific infrastructure: they run on any computer, on any infrastructure, and in any cloud**.
]

---
.left-column[
  ## What is it?
  ## Not a VM
  ## Containers!
  ## Why use it?
]
.right-column[
  ## To prevent this
  </br><center>
  ![](http://blogs.gartner.com/richard-watson/files/2015/05/Worked-Fine-In-Dev-Ops-Problem-Now.jpg)
  </center>
]

---
.left-column[
  ## What is it?
  ## Not a VM
  ## Containers!
  ## Why use it?
]
.right-column[
  ## And enable this
  </br><center>
  ![](http://blogs.gartner.com/richard-watson/files/2015/05/can-use-same-containers-tomorrow.jpg)
  </center>
]

---
class: center, middle, inverse

## Great! Show me how?!

---

## `Dockerfile`
Docker can build images automatically by reading the instructions from a `Dockerfile`. A `Dockerfile` is a text document that contains all the commands a user could call on the command line to assemble an image.

```shell
docker build -t myimage .
```

```shell
FROM ruby:2.3.1-slim

RUN mkdir /usr/src/people-in-space
WORKDIR /usr/src/people-in-space

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["ruby", "app.rb"]

```

---
## What do we know about our app?

```ruby
require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

def data
  JSON.parse(File.read('data.json'))
end

before do
  content_type :json
end

get '/' do
  data.to_json
end

get '/number' do
  { number: data['number'] }.to_json
end
```

---
.left-column[
  ## It's ruby
]
.right-column[
  ```shell
  FROM ruby:2.3.1-slim
  ```
]

---
.left-column[
  ## It's ruby
  ## It needs a home
]
.right-column[
  ```shell
  FROM ruby:2.3.1-slim

  RUN mkdir /usr/src/people-in-space
  WORKDIR /usr/src/people-in-space
  ```
]

---
.left-column[
  ## It's ruby
  ## It needs a home
  ## It has requirements
]
.right-column[
  ```shell
  FROM ruby:2.3.1-slim

  RUN mkdir /usr/src/people-in-space
  WORKDIR /usr/src/people-in-space

  COPY Gemfile Gemfile.lock ./
  RUN bundle install
  ```
]

---
.left-column[
  ## It's ruby
  ## It needs a home
  ## It has requirements
  ## It has code
]
.right-column[
  ```shell
  FROM ruby:2.3.1-slim

  RUN mkdir /usr/src/people-in-space
  WORKDIR /usr/src/people-in-space

  COPY Gemfile Gemfile.lock ./
  RUN bundle install

  COPY . .
  ```
]

---
.left-column[
  ## It's ruby
  ## It needs a home
  ## It has requirements
  ## It has code
  ## Code has to run
]
.right-column[
  ```shell
  FROM ruby:2.3.1-slim

  RUN mkdir /usr/src/people-in-space
  WORKDIR /usr/src/people-in-space

  COPY Gemfile Gemfile.lock ./
  RUN bundle install

  COPY . .

  CMD ["ruby", "app.rb"]
  ```
]

---
## `docker build -t sb-coders .`

```shell
Sending build context to Docker daemon 77.31 kB
Step 1/7 : FROM ruby:2.3.1-slim
 ---> e523958caea8
Step 2/7 : RUN mkdir /usr/src/people-in-space
 ---> Using cache
 ---> 2091c8d84dcc
Step 3/7 : WORKDIR /usr/src/people-in-space
 ---> Using cache
 ---> f5d74d965a9b
Step 4/7 : COPY Gemfile Gemfile.lock ./
 ---> e59dbdcc52b6
Removing intermediate container a0fd47abcbae
Step 5/7 : RUN bundle install
 ---> Running in 3363aa961dcd
...
Bundle complete! 1 Gemfile dependency, 5 gems now installed.
Bundled gems are installed into /usr/local/bundle.
 ---> effa93b84781
Removing intermediate container 3363aa961dcd
Step 6/7 : COPY . .
 ---> a77a3af55132
Removing intermediate container 0cd83ca5103a
Step 7/7 : CMD ruby app.rb
 ---> Running in 6248042fcc10
 ---> 933bf0ad4179
Removing intermediate container 6248042fcc10
Successfully built 933bf0ad4179
```

---
## `docker image list`

```shell
REPOSITORY  TAG     IMAGE ID        CREATED              SIZE
sb-coders   latest  933bf0ad4179    About a minute ago   292 MB
```

--
## `docker run ...`

```shell
docker run --name people-in-space \  # it's a good idea to name the container
  -p 8001:4567 \  # our app runs on 4567 inside the container, expose it to 8001
  sb-coders  # this is the image we're going to run
```

---
class: center, middle, inverse

## Prove it...

---

## [Hyper.sh](https://hyper.sh/)

*"Effortless Docker hosting. Deploy your containers in 5 sec!"*

```shell
$ hyper
Usage: hyper [OPTIONS] COMMAND [arg...]
       hyper [ --help | -v | --version ]

A self-sufficient runtime for containers.
```

--
```shell
docker build -t jadametz/sb-coders-demo .
docker push jadametz/sb-coders-demo
```

--
```shell
hyper run --name sb-coders -p 80:4567 -d jadametz/sb-coders-demo
hyper fip attach <hyper-fip> sb-coders
```
