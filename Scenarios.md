# Scenarios

## Intro and motivation

Upon researching the domain area and related work I came to rhe conclusion that the best method of requirements gathering to use for this project was to design Scenarios.

As discussed in the methodology section I am attempting to meet some aspects of the agile ideals as they apply to my project and circumstances, and so in that vein the requirements gathering process was happening alongside the requirements generation and system design planning. Therefore it became clear early on that it would be important to think about what kind of communication would be needed between the users and how much interactivity will this require and how will that be implemented were going to be important questions at a later date. Therefore it is improtant to think about what kind of communication is needed in each scenario and whether it is structured or not.

The reason I chose these

Upon brainstorming scenarios in which this app could be used I could think of three basic use cases. There are also a number of peripheral cases which I termed 'specialised scenarios'. These scenarios are not deemed within the realm of the core purpose of this app but may still be use cases the app is used frequently for, therefore they may still be worth considering when designing any solution.

The first of the primary scenarios I named "Lone Travel".

## Lone Travel

"The users are each travelling alone from different start-locations to the same destination. They may potentially have different start and arrival times, or wish to synchronise in some way."

In this use case the users do not necessarily need to have structured communication methods although one could imagine how it might be useful for structured communucation to be available anyway (e.g. handling changes to plans or unexpected issues in the journey) so it should still be considered in the design phase. But in this scenario structured communication is not a hard requirement. For a lone traveller the key user need to be met is sharing information between the users. This is how our app will be different to other applications that are available in this space. Therefore it is very important to spend time considering the design and requirements for this funtionality. Early thoughts suggest that thinking of it from a back end view it is simply required to present all of the information available in some structured way to the front end. It does then not need to worry about the internals of the data being shared. The front end can then display or not diplay data as required. This could also be and important separation of concerns from a security perspective.

It may also be nice to allow some unstructured communication between uses in the form of messaging or perhaps more hands free calling or usage of personal assistant apps such as Apple's Siri and Amazon's Alexa services. But this would certaintly not be a requirement in the initial version of the project. And at this point as I am writing it woud be hoped that the development cost of adding this feature could be outsourced to some library or else the cost may outweight the gain of adding such a feature.

As the project went on it became clear in later stages that requirements needed to be revisited and refined to add requirements and funtionality where necessary and scale back where needed to define the final minimum deliverable iteration of the project. Particularly the need for basic sat-nav functionality became more and more clear. Users expect not to have to sacrifice functionality in their current systems to move to a new sytem. Therefore common features in sat-nav systems such as turn-by-turn instructions, voice instructions, and a clear UI are expected requirements. The authentification and data processing needs were underestimated. I think it became clear that the warning that it is often easy to overcomplicate and overestimate on initial designs should have been more greatly heeded in early developent, but also I would recognise the value of learning that simply forging on and failing then re-adjusting to speed up development and iterate can often be better. I think I learnt the need to iterate and outsource development to dependencies to improve quality and efficiency and speed of development. But also I learnt it is key to constantly re-evalute and ensure you understand the structure and the goal of  the system you are building when working on a project such as this.


## Joint Journey

"The users are travelling from the same location to the same destination at the same time. They want to synchronise their journey, stopping at the same times, so they need a structured way to communicate these decisions without distracting themselves from the road."

DISCUSS
In this scenario the users' journeys are synchronised, meaning they travel at the same time and they travel together. This means that they will need to communicate in a structured way with all of the other users on the Convoy. Naturally the actual communication will be carried out using asynchronous technologies so-as not to disrupt the running of the app, but perhaps some synchronousity will need to be built as an abstraction at the view layer. There are a number of reasons users could need to communicate in the context of this scenario:
- Do they want to stop for a break? 
- Do they want to get food?
- Do they need petrol? 
- Are they having mechanical issues? 
- Where are you?

In this scenario the users may also require the app to help them stick together throughout the journey staying within eyesight of each other or within a certain distance so one user can lead the Convoy. They would need to accurately know where the other users are so they can stick together in this scenario. In addition to this, the user will expect other features associated with routing apps to be replicated as in the previous scenario and these will be hard requirements.

## Meet-In-The-Middle

"This scenario combines the previous two in that the users start at different locations but unite at some point in the middle before proceeding to the same destination, combning the needs of both previous scenarios."

DISCUSS
The primary need of this scenario is for the process of meeting in the middle to be smoothe. The users would prefer to minimise waiting times and meet at a location that is easy to find each other in and perhaps has amenities if the wait time will be long. This meet plan will need to be flexible in response to any issues that might arise on the journey to the meeting point such as traffic or mechanical issues.

I have decided to create scenarios as I think this style of requirements gathering is very suitable to this project. There are three main scenarios that I envision this app being used in as well as a few other more specialised scenarios that the are not the core purpose for the app but are contexts in which users could choose to use the app and so are still worth consideration during the design phases. I will first discuss the main scenarios, then briefly mention the secondary scenarios. I will write 2 descriptions for each scenario, the first a brief quotable description, the second a more in depth discussion of the needs of a user in this use case.

## Core Scenarios

### Lone Travel
#### Brief

The users are each travelling alone from different start-locations to the same destination. They may potentially have different start and arrival times, or wish to synchronise in some way.

#### Discussion

In this scenario the users do not need to communicate or interact in a structured way such as aligning food stops, petrol levels or any other issues that may arise, though it would still be useful to handle these issues within the app to create a single journey experience, these are not hard requirements. The fundamental need is to allow the users to update each other on their progress. Has the other user set off yet? Have they arrived? When will they arrive? Have they broken down? Where are they? It might also be useful to facilitate less structured communication betwen the users such as voice chat. In addition to this the user will expect other features associated with routing apps to be replicated. Some of these may be hard requirements, such as knowing when the user can expect to arrive, adjusting routes based on traffic warnings, communicationg traffic warnings to the user, blow-by-bow instructions e.g. 'Turn right in 50 yards'.


### Joint Journey

#### Brief

The users are travelling from the same location to the same destination at the same time. They want to synchronise their journey, stopping at the same times, so they need a structured way to communicate these decisions without distracting themselves from the road.

#### Discussion



### Meet-In-The-Middle

#### Brief

This scenario combines the previous two in that the users start at different locations but unite at some point in the middle before proceeding to the same destination, combning the needs of both previous scenarios.

#### Discussion



## Secondary Scenarios

### Same Start Location But Disconnected

#### Brief

In this Scenario the users start from the same location but might leave at different times and do not necessarily want to stick together.

### Follow the Leader

#### Brief

In this scenario one user is considered to have expertise either in driving or the routes. and so they are assigned to lead the convoy. They should be ahead of the other drivers and keeping together is more important. It is possible another driver lack confidence for some reason. Perhaps they aren't used to long periods at the wheel, or the route is difficult.

## Overall Discussion of Scenarios

For the Minimum Viable Product it is important to select a scenario to focus on to begin with. I will choose Lone Travel purely because it involves the least complexity and is the most versatile. Users in the other scenarios are most likely be able to use an app designed for the Lone Travel Scenario than an app designed for any of the others.

I think that given the time constraints, the secondary scenarios and the Meet in The Middle Scenario are out of the scope of this project.
