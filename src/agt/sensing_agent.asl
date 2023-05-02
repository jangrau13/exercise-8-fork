// sensing agent


/* Initial beliefs and rules */
role_goal(R, G) :- role_mission(R, _, M) & mission_goal(M, G).
can_achieve(G) :- .relevant_plans({+!G[scheme(_)]}, LP) & LP \== [].
i_have_plans_for(R) :- not (role_goal(R, G) & not can_achieve(G)).


/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").

+newOrg(WspName, OrgName) : true <-
	joinWorkspace(WspName, WspId);
	lookupArtifact(OrgName, OrgArtId);
	focus(OrgArtId);
	!focus_my_friend;
	!adopt_overcome;
	.print("focusing on ", OrgName).


 +!focus_my_friend : group(GrpName, _, _) & scheme(SchemeName, _, _) <-
	lookupArtifact(GrpName, GrpId);
	focus(GrpId);
	lookupArtifact(SchemeName, SchemeId);
	focus(SchemeId);
	.print("focused my friend: ", GrpId).


//react to I have a plan for
//	adoptRole(G);
+!adopt_overcome : role_goal(R, G) & can_achieve(G) <-
	adoptRole(R);
	.print("adopted role ", R).

/*
+!adopt_overcome : can_achieve (G) & role_goal(R, G) <-
	.print("role ", R);
	.print("goal ", G).
	*/

/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("I will read the temperature");
	makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
	focus(WeatherStationId); // focuses on the weather station artifact
	readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
	.print("Temperature Reading (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }