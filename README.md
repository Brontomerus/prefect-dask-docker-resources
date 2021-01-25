# Prefect Agent Docker Image

# Description
This alpine-python image is a production ready-ish lean & mean image for operating prefect images wherever you want to run it.

# Getting Started

docker run -d --init -e PREFECT_AGENT=local -e PREFECT_BACKEND=cloud -e PREFECT_CLOUD_TOKEN=[YOUR TOKEN HERE] -e LABELS="-l etl" [YOUR_CONTAINER_NAME_OR_ID]

### Environment Variables
- `PREFECT_AGENT`: [deafult = local] local, ecs, kubernetes, docker, etc. anything defined [here](https://docs.prefect.io/api/latest/cli/agent.html).
- `PREFECT_BACKEND`: [quasi-optional] backend or cloud.
- `PREFECT_CLOUD_TOKEN`: [**Optional] The RUNNER token from your prefect cloud account, if being used.
- `LABELS`: [**Optional] labels for your agent, need it in format "-l [LABEL 1] -l [LABEL 2] -l [LABEL 3] ..." see the format in the [Prefect documentation](https://docs.prefect.io/api/latest/cli/agent.html)
- `EXTRA EXTRA_PIP_PACKAGES`: [**Optional] Any additional pypi packages to install, separated by spaces. ie "dask-provider dask[complete] ezodbc"
- `EXTRA EXTRA_APK_PACKAGES`: [**Optional] Any additional apk packages needed to install the above extra pip packages. It's kept slim on purpose.

## Why I created this Image

The purpose of this docker image is to solve a few troubles I've run into regarding use of Prefect Agents. While it is entirely possible to run these in more than a few ways thanks to the team at Prefect, there were a few main pitfalls I personally ran into while translating my local testing environment to my [aws] cloud infrastructure. This set up proved rather confusing, and part of that was trying to understand how everything "fit" together (especially in my case, having to teach myself entirely). Adding the recent update from 13.9 to 14.0, and it was a recipe for confusion - I was lost with what exactly run_configs were, how they related to agents, and what exactly each main compenent _did_. 

While I could spin an EC2 instance up in a private subnet and run an agent just fine on the actual instance, I've noticed agents tend to have a lifetime, and would die or fall into disrepair after a period of innactivity or once I logged out of that private host. Another issue I ran into is if you are on same said private host, its somewhat difficult to half more than one agent running in there unless you're some type of linux sys admin wizard, which I am not. I'm hoping to use my better suited knowledge of docker processes to create something I, as well as others, can build on to spin these agents up more effectively in their own environments - wherever that may be.

There are a few main ideas behind the functionality of a deployed container:

1. Easily start prefect agents 
2. Build with respect your environment
3. Restart agents that have died or stopped working
4. tini to patrol PID1 and kill zombies (processes)
5. Keeping Security in Mind


## Explanation of Main Purposes:

### 1. Easily start prefect agents
Regardless of where the agents are running and what type of agent is being started, the container will provide the means to start the necessary process.


### 2. Build with respect your environment
Build the images with respect to your environment. Not to be confused with the "Environment" objects in Prefect 0.13.9, but what I use to describe what you have defined as your Storage, Run Config, and Executor. 

For example, if you are using S3 Storage or a DaskExecutor() using an AWS cluster of some flavor then it will assure to `pip install prefect[aws]`. If you are using Github storage, then it will `pip install prefect[github]`, and so on - so you don't have to worry about little details here.


### 3. Restart agents that have died or stopped working
If an agent stops running, then start a new process. Thats right, I want health checks. Regular physician visits for our agents. Employer-sponsored health-checks if you will.


### 4. tini to patrol PID1 and kill zombies (processes)
One process per container, everyone knows the rules. While I'm not an expert on prefect's agent code and inner workings from a-z, this can be explained best by Ronald Reagon's favorite proverb, "Trust, but verify". Plus, whats a cooler challenge than _killing zombies_? Perhaps building better docker images, but I'm trying my best over here.

### 5. Keeping Security in Mind
Following information [here](https://medium.com/asos-techblog/minimising-your-attack-surface-by-building-highly-specialised-docker-images-example-for-net-b7bb177ab647), shared by author Paulo Gomes, we want to build containers that drop all the jazz so they can be more readily run in production-hardened systems. The Hardened dockerfile references can also be verified on this github repo for [iron-alpine](https://github.com/ironpeakservices/iron-alpine/blob/master/Dockerfile#L45)

