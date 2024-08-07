/*********************************************
 * OPL 22.1.1.0 Model
 * Author: Shadow
 * Creation Date: 2024 8 5  at 4:25:54
 *********************************************/
range S= 1..2;//set of wood supplier
range F= 1..3;//set of factory location 
range D= 1..5; //set of distributor
range M= 1..4; //set of markets
range R= 1..4;//set of recycling centers
range W= 1..2;//set of products

//Parameters
float AS[S]=[10000, 10000]; //cost of agreement (i.e., fixed-cost) with bottle producers 
float AR[R]=[0.1, 0.1, 0.1, 0.1];//cost of agreement (i.e., fixed-cost) with recycling centers

//maximum capacity of wood producers vernon, kamloops
float CS[S][W]=[[6500,6500],[8000,8000]]; 
//purchasing cost from wood producers vernon, kamloops
float P[S][W]=[[35,10],[30,7]]; 

//maximum capacity of factory, 210 Lougheed Road (U), 1465 Ellis Street (D), 1505 Hardy Street(M)
float CF[F][W]=[[22*8*2*10, 22*8*4*10],[22*8*2*4, 22*8*4*4],[22*8*2*6, 22*8*4*6]];  

//cost of agreement (i.e., fixed-cost) with factory location, 1 year rate+fixed equipments
float AF[F]=[42000+5000, 20500+5000, 19760+5000];

//maximum capacity of distributors 1650 Springfield Road (HH),470 Highway #33 West (HH),2515 Enterprise Way (HD),2514 BC-97 (ASHLEY),1264 Ellis St (LH)
float CD[D][W]=[[300,500], [300,500],[300,500],[300,500],[300,500]];
float AD[D]=[25000, 25000, 25000,25000, 25000]; //cost of agreement (i.e., fixed-cost) with distributors 

//maximum capacity of recycling centers, Westside, Glenmore Landfill, Kelowna Recycling, Restore
float CR[R][W]=[[1000,1000],[1000,1000],[400,400],[100,150]];
//recycle cost from wood recyle centers
float N[R][W]=[[5,5],[5,5],[5,5],[5,5]]; 
//Recycle Cost Savings 
float K[W]=[10,5]; 
//Disposal Cost
float Q[W]=[0,0];

float Lsf[S][F]=[[78.5, 85.4, 83.7],
				 [161, 168, 166]];//transportation distance between locations S and F
				 
float Lfd[F][D]=[[9.1,5.5,6.2,5.3,11.1],
			     [3.8,8.3,5.5,6.5,0.6],
			     [1.9,5,1.9,2.9,4.2]];//transportation distance between locations F and D
	
float Ldm[D][M]=[[3.7,2.9,7.6,5.7],
				 [8.3,7,13.4,0.7],
				 [5.5,3.8,9.1,2.9],
				 [6.5,4.8,10.1,2.7],
				 [1,3.7,8.6,8.3]];//transportation distance between locations d and m

float Lmr[M][R]=[[16.6,11.7,3.6,4.2],
				[20.8,7.6,2.4,2.6],
				[24.6,17.5,8.4,8.1],
				[24,9,5.1,4]];//transportation distance between locations m and r
			 	 
float Lr[R]=[28.3,0,9.8,10];//transportation distance between locations r and z

float Lrf[R][F]=[[27.4,16.9,20.2],
				[4.4,11.6,9.8],
				[8.5,3.7,1.3],
				[7,4.3,0.65]];//transportation distance between locations r and f
//transportation of Euro 5 32-ton truck		
float O1=8/200; 	//$7.0875(fuel)+$0.567(driver)+$0.135(maintenance)+$0.0675(insurance and taxes)+$0.135(tolls)=$7.992CAD
float T1=200; 	//200 capacity
float E1=0.9;
//transportation of Ford F150, pickup truck
float O2=0.43;	//$0.243(fuel)+$0.0675(maintenance)+$0.0945(insurance and taxes)+$0.027(tolls)=$0.432CAD
float T2=1;		//1 capacity
float E2=0.277;

//downtown, glenmore, lower mission, rutland
float Demand[M][W]=[[300,300],[200,200],[200,400],[400,200]]; //demand of market m
float Return[M][W]=[[200,200],[150,150],[150,200],[200,50]]; //return of market m

float alpha=0.3;//recovery rate
float We1=0.8;//weight of total cost
dvar float+ We2;////weight of carbon emissions

dvar float+ Z1;//total cost
dvar float+ Z2;//carbon emissions

//Decision Variables
dvar float+ Usfw[S][F][W];
dvar float+ Wfdw[F][D][W];
dvar float+ Ydmw[D][M][W];
dvar float+ Xmrw[M][R][W];
dvar float+ Vrfw[R][F][W];
dvar float+ Zrw[R][W];

dvar boolean BS[S];//1, if the supplier is selected
dvar boolean BF[F];//1, if the factory location is selected
dvar boolean BD[D];//1, if the distributor is selected
dvar boolean BR[R];//1, if the recycle center is selected

minimize (We1* (Z1))+(We2* (Z2));
subject to {
Z1==sum(s in S)(AS[s]*BS[s])+sum(f in F)(AF[f]*BF[f])+sum(d in D)(AD[d]*BD[d])+sum(r in R)(AR[r]*BR[r])+
		sum(s in S, f in F, w in W)(O1*Lsf[s][f]*Usfw[s][f][w]+P[s][w]*Usfw[s][f][w])+
		sum(f in F, d in D, w in W)(O1*Lfd[f][d]*Wfdw[f][d][w])+
		sum(d in D, m in M, w in W)(O2*Ldm[d][m]*Ydmw[d][m][w])+
		sum(m in M, r in R, w in W)(O2*Lmr[m][r]*Xmrw[m][r][w]+N[r][w]*Xmrw[m][r][w])+
		sum(r in R, f in F, w in W)(O1*Lrf[r][f]*Vrfw[r][f][w]-K[w]*Vrfw[r][f][w])+
		sum(r in R, w in W)(O1*Lr[r]*Zrw[r][w]+Q[w]*Zrw[r][w]);
		
Z2==sum(s in S, f in F, w in W)(E1*Lsf[s][f]/T1*Usfw[s][f][w])+
		sum(f in F, d in D, w in W)(E1*Lfd[f][d]/T1*Wfdw[f][d][w])+
		sum(d in D, m in M, w in W)(E2*Ldm[d][m]/T2*Ydmw[d][m][w])+
		sum(m in M, r in R, w in W)(E2*Lmr[m][r]/T2*Xmrw[m][r][w])+
		sum(r in R, f in F, w in W)(E1*Lrf[r][f]/T1*Vrfw[r][f][w])+
		sum(r in R, w in W)(E1*Lr[r]/T1*Zrw[r][w]);
		
forall (f in F, w in W) {sum (d in D)Wfdw[f][d][w]==sum(s in S)Usfw[s][f][w]+sum(r in R)Vrfw[r][f][w];}
forall (r in R, w in W) {sum (m in M)Xmrw[m][r][w]==sum(f in F)Vrfw[r][f][w]+Zrw[r][w];}
forall (d in D, w in W) {sum (m in M)Ydmw[d][m][w]==sum(f in F)Wfdw[f][d][w];}

forall (m in M, w in W) {sum (d in D)Ydmw[d][m][w]==Demand[m][w];}
forall (m in M, w in W) {sum (r in R)Xmrw[m][r][w]==Return[m][w];}
forall (r in R, w in W) {sum (m in M)Xmrw[m][r][w]*alpha<=Zrw[r][w];}

forall (s in S, w in W) {sum (f in F)Usfw[s][f][w]<=CS[s][w]*BS[s];}
forall (f in F, w in W) {sum (d in D)Wfdw[f][d][w]<=CF[f][w]*BF[f];}
forall (d in D, w in W) {sum (m in M)Ydmw[d][m][w]<=CD[d][w]*BD[d];}
forall (r in R, w in W) {sum (m in M)Xmrw[m][r][w]<=CR[r][w]*BR[r];}

We1+We2==1;
BF[2]==1;
sum(f in F)(BF[f])==1;
} 

execute {
  writeln("Solution:");
  writeln("z1 = ", Z1);
  writeln("z2 = ", Z2);
}