-module(add_edit).
-compile(export_all).
-include_lib("nitrogen_core/include/wf.hrl").

main() -> #template { file="./site/templates/bare.html" }.

title() -> "Add New/Edit  WebLink".

get_linkid() ->
    case wf:path_info() of
	"new" ->
	    new;
	ID -> wf:to_integer(ID)
end.

body() ->
    LinkID = get_linkid(),
    Weblink = ni_links:get_link(LinkID),
    form(Weblink).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% State 2		  		     %%
%% User enter new link info; 		     %%
%% clicks Save				     %%
%% System saves new link info;	  	     %%
%% transitions back to inital state	     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

form(new) ->
    form(new,"","","");
    
form(Weblink) ->
    ID = ni_links:id(Weblink),
    Topic = ni_links:topic(Weblink),
    Desc = ni_links:descriptor(Weblink),
    Url = ni_links:url(Weblink),
    form(ID,Topic,Desc,Url).

form(ID,Topic,Desc,Url) ->
    wf:defer(save_link, topic,
        #validate{validators=[
            #is_required{text="Topic required"}]}),
    wf:defer(save_link, descriptor,
        #validate{validators=[
            #is_required{text="Descriptive text required"}]}),
     wf:defer(save_link, url,
         #validate{validators=[
             #is_required{text="URL required"},
	    #custom { text="Must be a valid url", 
		function=fun(url,Value) ->
                	    case Value of
			       "http://" ++ _ -> true;
			       "https://" ++ _ -> true;
		         	_ -> false
           		    end
		          end,tag=url }
]}),
    #panel {class="w3-card-4", body=
    [
    #panel {class="w3-container w3-green", body=[#h2 {text="Create or Edit Web Link"}]},
    #panel {class="w3-container", body=
    [
	#label{text="Topic"},
	#textbox{class="w3-input w3-border",id=topic,text=Topic},
	#label{text="Descriptive Text"},
	#textbox{class="w3-input w3-border",id=descriptor,text=Desc},
	#label{text="URL"},
	#textbox{class="w3-input w3-border",id=url,text=Url},
	#br{},
	#button {class="w3-btn w3-green", id=save_link , postback={save,ID}, text="Save" },
	#link{class="w3-btn w3-green",style="margin-left:10px",text="Cancel",url="/"}
    ]}]}.




event({save,ID}) ->    
    save(ID).

save(new) ->
    [Topic,Desc,Url] = wf:mq([topic,descriptor,url]),
    Weblink = ni_links:new(Topic,Desc,Url),
    save_and_redirect(Weblink);
save(Linkid) ->
    [Topic,Desc,Url] = wf:mq([topic,descriptor,url]),
    Weblink = ni_links:get_link(Linkid),
    Weblink2 = ni_links:topic(Weblink,Topic),
    Weblink3 = ni_links:descriptor(Weblink2,Desc),
    Weblink4 = ni_links:url(Weblink3,Url),
    save_and_redirect(Weblink4).

save_and_redirect(Weblink) ->
    ni_links:save_link(Weblink),
    wf:redirect("/").
    


