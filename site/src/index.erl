%% -*- mode: nitrogen -*-
-module (index).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "My Web Links".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial State			       %%
%% User choice: transition to "add new" form   %%
%% or enter search words and initates a search %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

body() ->
    [
	#h2{text = "State 1: Add new weblink or search for existing links"},
	#button{class="w3-btn w3-red",text="Add New", click=#redirect{url="/add_edit/new"}},
	#br{},
	#textbox { id=search_words, class="w3-input w3-border"},
	#button {class="w3-btn w3-blue", id=retrieve, text="Search", postback=search},
	#button {class="w3-btn w3-green",text="Show All", postback=show_all},
	#hr{},
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% State 3			  %%
%% System displays search results %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	#panel {id=search_results}
    ].

event(search) ->
    return_search_results();
event(show_all) ->
    show_all();
event({delete,LinkID,Linkwrapperid}) ->
    delete(LinkID,Linkwrapperid).

delete(LinkID,Linkwrapperid) ->
    ni_links:delete_link(LinkID),
    wf:remove(Linkwrapperid).


return_search_results() ->
    SearchString = wf:q(search_words),
    Links = ni_search:search(SearchString),
    SearchResultBody = draw_links(Links),
    wf:update(search_results,SearchResultBody).

draw_links(Links) ->
    #panel{class= "w3-panel w3-pale-green", id=show_links, body=[
	#h3{text="State 3: Return seach results"},
	[draw_link(Link) || Link <- Links]
	]}.

draw_link(Weblink) ->
    LinkId = ni_links:id(Weblink),
    Text = ni_links:descriptor(Weblink),
    Url = ni_links:url(Weblink),
    EditUrl = "add_edit/" ++ wf:to_list(LinkId),
    Menuid = wf:temp_id(),
    Linkwrapperid = wf:temp_id(),
    #panel{class="w3-panel",id=Linkwrapperid, body=[
	#link{ class="w3-text-green", 
	    text=Text,
	    click=#toggle{target=Menuid}
	},
	#panel {class="w3-bar w3-green",id=Menuid,style="display:none", body = [
	#link {class="w3-bar-item w3-button",text="view",url=Url},
	#link {class="w3-bar-item w3-button",text="edit",url=EditUrl},
	#link {class="w3-bar-item w3-button",text="delete",postback={delete,LinkId,Linkwrapperid}}
	    ]}
    ]}.

show_all() ->
    Links = ni_links:get_all(),
    AllBody = draw_links(Links),
    wf:update(search_results,AllBody).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% State 4					       %%
%% System displays record			       %%
%% User selects view, edit, or delete		       %%
%% if view, display web page			       %%
%% if edit, transition to edit_add.erl state 6 	       %%
%% if delete, delete record; transition to State 1     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       
    
 
