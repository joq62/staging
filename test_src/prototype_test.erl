%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(prototype_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
  %  io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start pass1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=pass1(),
    io:format("~p~n",[{"Stop pass1()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start leader()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=leader(),
    io:format("~p~n",[{"Stop leader()",?MODULE,?FUNCTION_NAME,?LINE}]),

   io:format("~p~n",[{"Start leader2()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=leader2(),
    io:format("~p~n",[{"Stop leader2()",?MODULE,?FUNCTION_NAME,?LINE}]),

 

 %   
      %% End application tests
  %  io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
  %  io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.
 %  io:format("application:which ~p~n",[{application:which_applications(),?FUNCTION_NAME,?MODULE,?LINE}]),

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
pass1()->
    [L1,L2,L3]=sd:get(loader),
    [rpc:call(MyAdd,init,stop,[],5000)||MyAdd<-rpc:call(L2,sd,get,[myadd],3000)],
    timer:sleep(2000),
    
    {ok,Myadd1}=rpc:call(L1,loader,create,[],5000),
    ok=rpc:call(L1,loader,load_appl,[myadd,Myadd1],10000),
    ok=rpc:call(L1,loader,start_appl,[myadd,Myadd1],10000),
    timer:sleep(2000),
    [MyaddInstance]=sd:get(myadd),
    42=rpc:call(MyaddInstance,myadd,add,[20,22],1000),
    
    ok=rpc:call(L1,loader,load_appl,[mydivi,Myadd1],10000),
    ok=rpc:call(L1,loader,start_appl,[mydivi,Myadd1],10000),
    
    [MyDiviInstance]=sd:get(mydivi),
    42.0=rpc:call(MyDiviInstance,mydivi,divi,[840,20],1000),

    % io:format("Res ~p~n",[{Res,?FUNCTION_NAME,?MODULE,?LINE}]),
    
    [rpc:call(X,init,stop,[],5000)||X<-rpc:call(L2,sd,get,[myadd],3000)],
    [rpc:call(Y,init,stop,[],5000)||Y<-rpc:call(L2,sd,get,[mydivi],3000)],
    timer:sleep(2000),
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
leader()->
    [L1,L2,L3]=sd:get(loader),
    % 1.  Create worker vm and load sd 
    {ok,Myadd1}=rpc:call(L1,loader,create,[],5000),
    ok=rpc:call(L1,loader,load_appl,[sd,Myadd1],10000),
    ok=rpc:call(L1,loader,start_appl,[sd,Myadd1],10000),
    % 1. Load and start the application that uses leader
    ok=rpc:call(L1,loader,load_appl,[myadd,Myadd1],10000),
    ok=rpc:call(L1,loader,start_appl,[myadd,Myadd1],10000),

    % 1 .Load and start the application leader    
    ok=rpc:call(Myadd1,application,set_env,[[{leader,[{application,myadd}]}]],10000),
    ok=rpc:call(L1,loader,load_appl,[leader,Myadd1],10000),
    ok=rpc:call(L1,loader,start_appl,[leader,Myadd1],10000),
    
    % Test 1 
    Myadd1=rpc:call(Myadd1,leader,who_is_leader,[]),

    % 2.  Create worker vm and load sd 
    {ok,Myadd2}=rpc:call(L2,loader,create,[],5000),
    ok=rpc:call(L2,loader,load_appl,[sd,Myadd2],10000),
    ok=rpc:call(L2,loader,start_appl,[sd,Myadd2],10000),
    % 2. Load and start the application that uses leader
    ok=rpc:call(L2,loader,load_appl,[myadd,Myadd2],10000),
    ok=rpc:call(L2,loader,start_appl,[myadd,Myadd2],10000),

    % 2 .Load and start the application leader    
    ok=rpc:call(Myadd2,application,set_env,[[{leader,[{application,myadd}]}]],10000),
    ok=rpc:call(L2,loader,load_appl,[leader,Myadd2],10000),
    ok=rpc:call(L2,loader,start_appl,[leader,Myadd2],10000),
    
    % Test 2 
    Myadd1=rpc:call(Myadd1,leader,who_is_leader,[]),
    Myadd1=rpc:call(Myadd2,leader,who_is_leader,[]),

    % 3.  Create worker vm and load sd 
    {ok,Myadd3}=rpc:call(L3,loader,create,[],5000),
    ok=rpc:call(L3,loader,load_appl,[sd,Myadd3],10000),
    ok=rpc:call(L3,loader,start_appl,[sd,Myadd3],10000),
    % 3. Load and start the application that uses leader
    ok=rpc:call(L3,loader,load_appl,[myadd,Myadd3],10000),
    ok=rpc:call(L3,loader,start_appl,[myadd,Myadd3],10000),

    % 3 .Load and start the application leader    
    ok=rpc:call(Myadd3,application,set_env,[[{leader,[{application,myadd}]}]],10000),
    ok=rpc:call(L3,loader,load_appl,[leader,Myadd3],10000),
    ok=rpc:call(L3,loader,start_appl,[leader,Myadd3],10000),
    
    % Test 3
    Myadd1=rpc:call(Myadd1,leader,who_is_leader,[]),
    Myadd1=rpc:call(Myadd2,leader,who_is_leader,[]),
    Myadd1=rpc:call(Myadd3,leader,who_is_leader,[]),
    

    % Kill leader 
    rpc:call(Myadd1,init,stop,[]),
    timer:sleep(2100),

    io:format("Myadd1 ~p~n",[{Myadd1,?FUNCTION_NAME,?MODULE,?LINE}]),
    io:format("Myadd2 ~p~n",[{Myadd2,?FUNCTION_NAME,?MODULE,?LINE}]),
    io:format("Myadd3 ~p~n",[{Myadd3,?FUNCTION_NAME,?MODULE,?LINE}]),
    
    Myadd2=rpc:call(Myadd2,leader,who_is_leader,[]),
    Myadd2=rpc:call(Myadd3,leader,who_is_leader,[]),
    
    
    
    
 %   ok=rpc:call(L1,loader,load_appl,[leader,Myadd1],10000),
 %   ok=rpc:call(L1,loader,start_appl,[leader,Myadd1],10000),    


    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
leader2()->
    [L1,L2,L3]=sd:get(loader),
    % 1.  Create worker vm and load sd 
    {ok,App1}=rpc:call(L1,loader,create,[],5000),
    ok=rpc:call(L1,loader,load_appl,[sd,App1],10000),
    ok=rpc:call(L1,loader,start_appl,[sd,App1],10000),
    % 1. Load and start the application that uses leader
    ok=rpc:call(L1,loader,load_appl,[mydivi,App1],10000),
    ok=rpc:call(L1,loader,start_appl,[mydivi,App1],10000),

    % 1 .Load and start the application leader    
    ok=rpc:call(App1,application,set_env,[[{leader,[{application,mydivi}]}]],10000),
    ok=rpc:call(L1,loader,load_appl,[leader,App1],10000),
    ok=rpc:call(L1,loader,start_appl,[leader,App1],10000),
    
    % Test 1 
    App1=rpc:call(App1,leader,who_is_leader,[]),

    % 2.  Create worker vm and load sd 
    {ok,App2}=rpc:call(L2,loader,create,[],5000),
    ok=rpc:call(L2,loader,load_appl,[sd,App2],10000),
    ok=rpc:call(L2,loader,start_appl,[sd,App2],10000),
    % 2. Load and start the application that uses leader
    ok=rpc:call(L2,loader,load_appl,[mydivi,App2],10000),
    ok=rpc:call(L2,loader,start_appl,[mydivi,App2],10000),

    % 2 .Load and start the application leader    
    ok=rpc:call(App2,application,set_env,[[{leader,[{application,mydivi}]}]],10000),
    ok=rpc:call(L2,loader,load_appl,[leader,App2],10000),
    ok=rpc:call(L2,loader,start_appl,[leader,App2],10000),
    
    % Test 2 
    App1=rpc:call(App1,leader,who_is_leader,[]),
    App1=rpc:call(App2,leader,who_is_leader,[]),

    % 3.  Create worker vm and load sd 
    {ok,App3}=rpc:call(L3,loader,create,[],5000),
    ok=rpc:call(L3,loader,load_appl,[sd,App3],10000),
    ok=rpc:call(L3,loader,start_appl,[sd,App3],10000),
    % 3. Load and start the application that uses leader
    ok=rpc:call(L3,loader,load_appl,[mydivi,App3],10000),
    ok=rpc:call(L3,loader,start_appl,[mydivi,App3],10000),

    % 3 .Load and start the application leader    
    ok=rpc:call(App3,application,set_env,[[{leader,[{application,mydivi}]}]],10000),
    ok=rpc:call(L3,loader,load_appl,[leader,App3],10000),
    ok=rpc:call(L3,loader,start_appl,[leader,App3],10000),
    
    % Test 3
    App1=rpc:call(App1,leader,who_is_leader,[]),
    App1=rpc:call(App2,leader,who_is_leader,[]),
    App1=rpc:call(App3,leader,who_is_leader,[]),
    

    % Kill leader 
    rpc:call(App1,init,stop,[]),
    timer:sleep(2100),

    io:format("App1 ~p~n",[{App1,?FUNCTION_NAME,?MODULE,?LINE}]),
    io:format("App2 ~p~n",[{App2,?FUNCTION_NAME,?MODULE,?LINE}]),
    io:format("App3 ~p~n",[{App3,?FUNCTION_NAME,?MODULE,?LINE}]),
    
    App2=rpc:call(App2,leader,who_is_leader,[]),
    App2=rpc:call(App3,leader,who_is_leader,[]),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
  
           % suppor debugging
    ok=application:start(sd),

    % connect cluster
    Res=[{N,net_adm:ping(N)}||N<-test_nodes:get_nodes()],
    [{h200@c100,pong},
     {h201@c100,pong},
     {h202@c100,pong}]=lists:sort(Res),
   
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
