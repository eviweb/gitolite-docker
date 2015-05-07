Gitolite Docker
===============
Gitolite container
Install
-------
* clone this repository: `git clone https://github.com/eviweb/gitolite-docker.git`
* add your ssh public key in `gitolite-docker/.user-keys` directory if needed, otherwise a default key will be generated and named as the value of the `$USER` environment variable
* run the build file `gitolite-docker/build`

This will build an image named _gitolite-docker_

SSH Configuration
-----------------
In order to use a container as a gitolite server, you need to configure your ssh client.
This is done by adding some settings in you ssh configuration file: `~/.ssh/config`

As an example:

> we assume that:
> * the username is: `user`
> * gitolite-docker repository was cloned under: `~/gitolite-docker`
> * the ssh configuration file is: `~/.ssh/config`
> * the ssh port will be mapped to the local port: `2222`
> * no personal ssh public key was provided, so the ssh key to use is: `~/gitolite-docker/.user-keys/user`

```
Host gitolite-docker
	Port 2222
	Hostname localhost
	User git
	IdentityFile ~/gitolite-docker/.user-keys/user.pub
```

Create a container
------------------
### To serve gitolite
Run the command: `docker run -d -p 2222:22 --name=gitolite-docker -ti gitolite-docker:latest`

This will create a container named `gitolite-docker`.

Then you should be able to clone the gitolite-admin repository by running: `git clone git@gitolite-docker:gitolite-admin`
-- _You should be prompted to valid the server ssh key during the first connection_

### To run a command
Run the command: `docker run --name=gitolite-test-runner gitolite-docker:latest "YOUR QUOTED COMMAND"` where _"YOUR QUOTED COMMAND"_ is the command to run... Between quotes !

Example: `docker run --name=gitolite-test-runner gitolite-docker:latest "cd gitolite && GITOLITE_TEST=y prove"` which will run all gitolite tests.
