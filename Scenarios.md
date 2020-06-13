# Scenarios

## Intro and motivation

Upon researching the domain area and related work in section X, I came to the conclusion that the best method of requirements gathering to use for this project was to design Scenarios.

SCENARIOS RESEARCH

As discussed in the methodology section I am attempting to meet some aspects of the agile ideals as they apply to my project and circumstances, and so in that vein the requirements gathering process was concurrently to all other phases and throughout the project. Therefore it became clear early on that it would be important to think about what kind of communication would be needed between the users when thinking about the requirements and design of the app. I knew when coming up with the scenarios that how much interactivity any communication would require and how will that communication would be implemented were going to be important questions at a later date.

As a general principle unstructured communication and data transfer will require less development work but in the context of a navigation app that will be used while driving it may be preferable to prioritise user experience over development ease in some cases.

Upon brainstorming scenarios in which this app could be used I could think of three basic use cases. There are also a number of peripheral cases which I termed 'specialised scenarios'. These scenarios are not deemed within the realm of the core purpose of this app but may still be use cases the app is used frequently for, therefore they may still be worth considering when designing any solution.

The first of the primary scenarios I named "Lone Travel".

## Lone Travel

"The users are each travelling alone from different start-locations to the same destination. They may potentially have different start and arrival times, or wish to synchronise in some way."

In this use case the users do not necessarily need to have structured communication methods although one could imagine how it might be useful for structured communucation to be available anyway (e.g. handling changes to plans or unexpected issues in the journey) so it should still be considered in the design phase. But in this scenario structured communication is not a hard requirement. For a lone traveller the key user need to be met is sharing information between the users. This is how our app will be different to other applications that are available in this space. Therefore it is very important to spend time considering the design and requirements for this funtionality. Early thoughts suggest that thinking of it from a back end view it is simply required to present all of the information available in some structured way to the front end. It does then not need to worry about the internals of the data being shared. The front end can then display or not diplay data as required. This could also be and important separation of concerns from a security perspective.

It may also be nice to allow some unstructured communication between uses in the form of messaging or perhaps more hands free calling or usage of personal assistant apps such as Apple's Siri and Amazon's Alexa services. But this would certaintly not be a requirement in the initial version of the project. And at this point as I am writing it woud be hoped that the development cost of adding this feature could be outsourced to some library or else the cost may outweight the gain of adding such a feature.

As the project went on it became clear in later stages that requirements needed to be revisited and refined to add requirements and funtionality where necessary and scale back where needed to define the final minimum deliverable iteration of the project. Particularly the need for basic sat-nav functionality became more and more clear. Users expect not to have to sacrifice functionality in their current systems to move to a new sytem. Therefore common features in sat-nav systems such as turn-by-turn instructions, voice instructions, and a clear UI are expected requirements. The authentification and data processing needs were underestimated. I think it became clear that the warning that it is often easy to overcomplicate and overestimate on initial designs should have been more greatly heeded in early developent, but also I would recognise the value of learning that simply forging on and failing then re-adjusting to speed up development and iterate can often be better. I think I learnt the need to iterate and outsource development to dependencies to improve quality and efficiency and speed of development. But also I learnt it is key to constantly re-evalute and ensure you understand the structure and the goal of  the system you are building when working on a project such as this.


## Joint Journey

"The users are travelling from the same location to the same destination at the same time. They want to synchronise their journey, stopping at the same times, so they need a structured way to communicate these decisions without distracting themselves from the road."

In this scenario the users' journeys are synchronised, meaning they travel at the same time and they travel together. This means that they will need to communicate in a structured way with all of the other users on the Convoy. Naturally the actual communication will be carried out using asynchronous technologies so-as not to disrupt the running of the app, but perhaps some synchronousity will need to be built as an abstraction at the view layer. There are a number of reasons users could need to communicate in the context of this scenario:
- Do they want to stop for a break? 
- Do they want to get food?
- Do they need petrol? 
- Are they having mechanical issues? 
- Where are you?

In this scenario the users may also require the app to help them stick together throughout the journey staying within eyesight of each other or within a certain distance. Other users may not require such strict controls so while this is not a hard requirement for the MVP, it would significantly improve the value of the app to the user if the experience could bemore customisable. For example if a user could choose wheter or not they want to wait for the other user if they are separated or continue alone. However, if they did choose to stick together, they would need to accurately know where the other users in their Convoy are located so that they can stick together in this scenario. In addition to this, the user will expect other features associated with routing apps to be replicated as in the previous scenario and these will be hard requirements.

## Meet-In-The-Middle

"This scenario combines the previous two in that the users start at different locations but unite at some point in the middle before proceeding to the same destination, combining the needs of both previous scenarios."

The primary requirement of this scenario that differs from the others is the process of meeting in the middle. This would preferably be done at the most efficient location both pravtically and from a implementation viewpoint. Ideally, the app would be able to predict wheter a meeting location will be convenient, for example choosing to meet in a quiet car park rather than on a busy one way street. The users would prefer to minimise waiting times and meet at a location that is easy to find each other in and perhaps has amenities if the time spent waiting for another user is estimated to be significant. This meeting plan will need to be flexible in response to any issues that might arise on the journey to the meeting point such as traffic or mechanical issues or users taking a wrong turn. THis aspect of the experience will need to be tailored to be straightforward for the user fine tuning the accuracy and responsiveness of the app as well as the user experience. This part of the app will need to be quite failure proof and well tested as users will likely be frustrated if this feature is unreliable.

As mentioned earlier there were also some "specialised scenarios" that I considered, the first of these I named "Same Start Location But Disconnected".

"In this Scenario the users start from the same location but might leave at different times and do not necessarily want to stick together."

This scenario is very similar to the "Joint Journey" Scenario but it mandates that the users would be less connected and care less about synchronising their journey. It became clear as the design went on that creating requirements based on this scenario would be far too optimistic within the timeframe of this project. At some point further in the development beyond the scope of this project the app may specifically have features to deal with this scenario, but at this stage it is likely users in this scenario will simply adapt their usage of the Joint Journey features as this scenario does not fall under the remit of this initial project.

The other "specialised scenario" I considered I named "Follow The Leader".

"In this scenario one user is considered to have expertise either in driving or the routes. and so they are assigned to lead the convoy. They should be ahead of the other drivers and keeping together is more important. It is possible another driver lack confidence for some reason. Perhaps they aren't used to long periods at the wheel, or the route is difficult."

Again this scenario is very similar to the "Joint Journey" scenario and due to time constraints it was decided that no requirements for this scenario would fall under the remit of this project.

## Conclusion

For the Minimum Viable Product it is important to select a scenario to focus on to begin with. I will choose Lone Travel purely because it involves the least complexity and is the most versatile. Users in the other scenarios are most likely be able to use an app designed for the Lone Travel Scenario than an app designed for any of the others.

I think that given the time constraints, the secondary scenarios and the Meet in The Middle Scenario are out of the scope of this project.
