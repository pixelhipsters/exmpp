% $Id$

%% @author Jean-Sébastien Pédron <js.pedron@meetic-corp.com>

%% @doc
%% The module <strong>{@module}</strong> provides utilities to prepare
%% common XMPP stanzas.
%%
%% <h3>Stream handling</h3>
%%
%% <p>
%% {@module} provides 3 functions to:
%% </p>
%% <ul>
%% <li>Open a stream to an XMPP server</li>
%% <li>Open a stream in reply to initiating peer</li>
%% <li>Close a stream (regardless who has intiated the stream)</li>
%% </ul>
%%
%% <p>
%% A common use case is illustrated in <em>table 1</em>.
%% </p>
%% <table class="illustration">
%% <caption>Table 1: stream opening and closing</caption>
%% <tr>
%% <th>Client-side</th>
%% <th>Server-side</th>
%% </tr>
%% <tr>
%% <td>
%% <p>
%% The client call `{@module}':
%% </p>
%% <pre>Opening = exmpp_factory:stream_opening([
%%   {context, client},
%%   {to, "jabber.example.com"},
%%   {version, "1.0"}<br/>]).</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;stream:stream xmlns:stream="http://etherx.jabber.org/streams"
%%   xmlns="jabber:client" to="jabber.example.org" version="1.0"&gt;</pre>
%% </td>
%% <td></td>
%% </tr>
%% <tr>
%% <td></td>
%% <td>
%% <p>
%% If the server accepts the client stream opening, it'll call:
%% </p>
%% <pre>Opening_Reply = exmpp_factory:stream_opening_reply(Opening).</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;stream:stream xmlns:stream="http://etherx.jabber.org/streams"
%%   xmlns="jabber:client" version="1.0" from="jabber.example.org"
%%   id="396429316"&gt;</pre>
%% <p>
%% Note that `{@module}' generated an ID automatically; you may override
%% this.
%% </p>
%% </td>
%% </tr>
%% <tr>
%% <td>
%% <p>
%% At the end of the communication, the client close its stream:
%% </p>
%% <pre>Client_Closing = exmpp_factory:stream_closing().</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;/stream:stream"&gt;</pre>
%% </td>
%% <td></td>
%% </tr>
%% <tr>
%% <td></td>
%% <td>
%% <p>
%% The server do the same:
%% </p>
%% <pre>Server_Closing = exmpp_factory:stream_closing(Client_Closing).</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;/stream:stream"&gt;</pre>
%% <p>
%% The server may use the same function clause than the client but here,
%% it gives the client closing to the function. This is to be sure to
%% use the same XML prefix.
%% </p>
%% </td>
%% </tr>
%% </table>
%%
%% <h3>Authentication</h3>
%%
%% <p>
%% In its current version, {@module} implements only the legacy
%% authentication mechanism.
%% </p>
%%
%% <p>
%% Again, a common use case is presented in <em>table 2</em>.
%% </p>
%% <table class="illustration">
%% <caption>Table 1: stream opening and closing</caption>
%% <tr>
%% <th>Client-side</th>
%% <th>Server-side</th>
%% </tr>
%% <tr>
%% <td>
%% <p>
%% Once a stream is opened, the client call `{@module}':
%% </p>
%% <pre>Request = exmpp_factory:legacy_auth_request("jabber.example.com").</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;iq xmlns="jabber:client" type="get" to="jabber.example.com"
%%   id="auth-1905181425"&gt;
%%       &lt;query xmlns="jabber:iq:auth"/&gt;<br/>&lt;/iq&gt;</pre>
%% </td>
%% <td></td>
%% </tr>
%% <tr>
%% <td></td>
%% <td>
%% <p>
%% The server answer with the available fields:
%% </p>
%% <pre>Request_Id = exmpp_xml:get_attribute(Request, 'id'),<br/>Fields = exmpp_factory:legacy_auth_fields(Request_Id).</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;iq xmlns="jabber:client" type="result" id="auth-1905181425"&gt;
%%       &lt;query xmlns="jabber:iq:auth"&gt;
%%               &lt;username/&gt;
%%               &lt;password/&gt;
%%               &lt;digest/&gt;
%%               &lt;resource/&gt;
%%       &lt;/query&gt;<br/>&lt;/iq&gt;</pre>
%% <p>
%% At this time, this function doesn't offer the possibility to choose
%% which field to include (one may not want to propose `<password/>' for
%% instance). And because {@link exmpp_xml} doesn't provide a function
%% to remove element yet, the only way to achieve this is to walk
%% through the children and remove it by hand.
%% </p>
%% </td>
%% </tr>
%% <tr>
%% <td>
%% <p>
%% The client can send its credentials; he choose `<digest/>':
%% </p>
%% <pre>Password = exmpp_factory:legacy_auth_password_digest(
%%   "johndoe",
%%   "foobar!",
%%   "home"<br/>).</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;q xmlns="jabber:client" type="set" id="auth-3105434037"&gt;
%%       &lt;query xmlns="jabber:iq:auth"&gt;
%%               &lt;username&gt;johndoe&lt;/username&gt;
%%               &lt;digest&gt;
%%                       93fdad2a795c59c73a6acf68a4dbdd3ddb366239
%%               &lt;/digest&gt;
%%               &lt;resource&gt;home&lt;/resource&gt;
%%       &lt;/query&gt;<br/>&lt;/iq&gt;</pre>
%% </td>
%% <td></td>
%% </tr>
%% <tr>
%% <td></td>
%% <td>
%% <p>
%% If the password is correct, the server notify the client:
%% </p>
%% <pre>Password_Id = exmpp_xml:get_attribute(Password, 'id'),<br/>Success = exmpp_factory:legacy_auth_success(Password_Id).</pre>
%% <p>
%% After serialization, this produces this XML message:
%% </p>
%% <pre>&lt;iq xmlns="jabber:client" type="result" id="auth-3105434037"/&gt;</pre>
%% </td>
%% </tr>
%% </table>

-module(exmpp_factory).
-vsn('$Revision$').

-include("exmpp.hrl").

-export([
	stream_opening/1,
	stream_opening_reply/1,
	stream_closing/0,
	stream_closing/1
]).
-export([
	legacy_auth_request/1,
	legacy_auth_request/2,
	legacy_auth_fields/1,
	legacy_auth_password/3,
	legacy_auth_password/4,
	legacy_auth_password_digest/3,
	legacy_auth_password_digest/4,
	legacy_auth_success/1,
	legacy_auth_failure/2
]).

% --------------------------------------------------------------------
% Stream opening/closing.
% --------------------------------------------------------------------

%% @spec (Args) -> Stream_Opening | {error, Reason}
%%     Args = [Arg]
%%     Arg = Context_Spec | To_Spec | Version_Spec | Lang_Spec
%%     Context_Spec = {context, client} | {context, server}
%%     To_Spec = {to, string()}
%%     Version_Spec = {version, string()}
%%     Lang_Spec = {lang, string()}
%%     Stream_Opening = exmpp_xml:xmlnselement()
%% @doc Make a `<stream>' opening tag.
%%
%% This element is supposed to be sent by the initiating peer
%% to the receiving peer (for the other way around, see {@link
%% stream_opening_reply/1}).
%%
%% Only `Context_Spec' is mandatory. It indicates if the stream to be
%% opened is between a client and a server (`client') or between two
%% servers (`server').

stream_opening(Args) ->
	case stream_opening_attributes(Args) of
		{error, Reason} ->
			{error, Reason};
		Attrs ->
			Stream_Opening = #xmlnselement{
				ns     = ?NS_XMPP,
				prefix = "stream",
				name   = stream,
				attrs  = Attrs
			},
			case check_stream_opening(Stream_Opening) of
				ok ->
					Stream_Opening;
				{error, Reason} ->
					{error, Reason}
			end
	end.

stream_opening_attributes(Args) ->
	stream_opening_attributes2(Args, []).

stream_opening_attributes2([{to, To} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'to', To),
	stream_opening_attributes2(Rest, New_Attrs);
stream_opening_attributes2([{version, Version} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'version', Version),
	stream_opening_attributes2(Rest, New_Attrs);
stream_opening_attributes2([{lang, Lang} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    ?NS_XML, 'lang', Lang),
	stream_opening_attributes2(Rest, New_Attrs);
stream_opening_attributes2([{context, client} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'xmlns', atom_to_list(?NS_JABBER_CLIENT)),
	stream_opening_attributes2(Rest, New_Attrs);
stream_opening_attributes2([{context, server} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'xmlns', atom_to_list(?NS_JABBER_SERVER)),
	stream_opening_attributes2(Rest, New_Attrs);
stream_opening_attributes2([{context, Bad_Context} | _Rest], _Attrs) ->
	{error, {unknown_context, Bad_Context}};
	
stream_opening_attributes2([Bad_Arg | _Rest], _Attrs) ->
	{error, {unknown_argument, Bad_Arg}};

stream_opening_attributes2([], Attrs) ->
	Attrs.

check_stream_opening(Stream_Opening) ->
	case exmpp_xml:has_attribute(Stream_Opening, 'xmlns') of
		true ->
			ok;
		false ->
			{error, unspecified_context}
	end.

%% @spec (Stream_Opening | Args) -> Stream_Opening_Reply
%%     Stream_Opening = exmpp_xml:xmlnselement()
%%     Args = [Arg]
%%     Arg = Context_Spec | From_Spec | ID_Spec | Version_Spec | Lang_Spec
%%     Context_Spec = {context, client} | {context, server}
%%     From_Spec = {from, string()}
%%     ID_Spec = {id, string()} | {if, undefined}
%%     Version_Spec = {version, string()}
%%     Lang_Spec = {lang, string()}
%%     Stream_Opening_Reply = exmpp_xml:xmlnselement()
%% @doc Make a `<stream>' opening reply tag.
%%
%% This element is supposed to be sent by the receiving peer in reply
%% to the initiating peer (for the other way around, see {@link
%% stream_opening/1}).
%%
%% Only `Context_Spec' is mandatory (see {@link stream_opening/1} for
%% its meaning).
%%
%% If `ID_Spec' is `{id, undefined}', one will be generated
%% automatically.

stream_opening_reply(#xmlnselement{attrs = Attrs} = Stream_Opening) ->
	Id = stream_id(),
	Attrs1 = exmpp_jlib:rename_attr_to_to_from_in_list(Attrs),
	Attrs2 = exmpp_xml:set_attribute_in_list(Attrs1, 'id', Id),
	Stream_Opening#xmlnselement{attrs = Attrs2};

stream_opening_reply(Args) ->
	case stream_opening_reply_attributes(Args) of
		{error, Reason} ->
			{error, Reason};
		Attrs ->
			Stream_Opening_Reply = #xmlnselement{
				ns     = ?NS_XMPP,
				prefix = "stream",
				name   = stream,
				attrs  = Attrs
			},
			case check_stream_opening_reply(Stream_Opening_Reply) of
				ok ->
					Stream_Opening_Reply;
				{error, Reason} ->
					{error, Reason}
			end
	end.

stream_opening_reply_attributes(Args) ->
	stream_opening_reply_attributes2(Args, []).

stream_opening_reply_attributes2([{from, From} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'from', From),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{id, undefined} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'id', stream_id()),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{id, ID} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'id', ID),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{version, Version} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'version', Version),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{lang, Lang} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    ?NS_XML, 'lang', Lang),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{context, client} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'xmlns', atom_to_list(?NS_JABBER_CLIENT)),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{context, server} | Rest], Attrs) ->
	New_Attrs = exmpp_xml:set_attribute_in_list(Attrs,
	    'xmlns', atom_to_list(?NS_JABBER_SERVER)),
	stream_opening_reply_attributes2(Rest, New_Attrs);
stream_opening_reply_attributes2([{context, Bad_Context} | _Rest], _Attrs) ->
	{error, {unknown_context, Bad_Context}};
	
stream_opening_reply_attributes2([Bad_Arg | _Rest], _Attrs) ->
	{error, {unknown_argument, Bad_Arg}};

stream_opening_reply_attributes2([], Attrs) ->
	Attrs.

check_stream_opening_reply(Stream_Opening_Reply) ->
	case exmpp_xml:has_attribute(Stream_Opening_Reply, 'xmlns') of
		true ->
			ok;
		false ->
			{error, unspecified_context}
	end.

%% @spec () -> Stream_Closing
%%     Stream_Closing = exmpp_xml:xmlnsendelement()
%% @doc Make a `</stream>' closing tag.

stream_closing() ->
	#xmlnsendelement{ns = ?NS_XMPP, prefix = "stream", name = 'stream'}.

%% @spec (Stream_Opening) -> Stream_Closing
%%     XML_End_Element = exmpp_xml:xmlnsendelement()
%% @doc Make a `</stream>' closing tag from the given `Stream_Opening' tag.

stream_closing(#xmlnselement{ns = NS, prefix = Prefix, name = Name}) ->
	#xmlnsendelement{ns = NS, prefix = Prefix, name = Name}.

%% @spec () -> Stream_ID
%%     Stream_ID = string()
%% @doc Generate a random stream ID.
%%
%% This function uses {@link random:uniform/1}. It's up to the caller to
%% seed the generator.

stream_id() ->
	integer_to_list(random:uniform(65536 * 65536)).

% --------------------------------------------------------------------
% Authentication elements.
% --------------------------------------------------------------------

%% @spec (To) -> Auth_Iq
%%     To = string()
%% @doc Make an `<iq>' for requesting legacy authentication.
%%
%% The stanza `id' is generated automatically.

legacy_auth_request(To) ->
	legacy_auth_request(auth_id(), To).

%% @spec (Id, To) -> Auth_Iq
%%     Id = string()
%%     To = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' for requesting legacy authentication.

legacy_auth_request(Id, To) ->
	% Make empty query.
	Query = #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'query',
	    children = []},
	% Make IQ.
	Iq = exmpp_xml:set_attributes(
	    #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'}, [
	    {'type', "get"},
	    {'to',   To},
	    {'id',   Id}]),
	exmpp_xml:append_child(Iq, Query).

%% @spec (Id) -> Auth_Iq
%%     Id = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' for advertising fields.

legacy_auth_fields(Id) ->
	% Prepare fields.
	Username = #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'username',
	    children = []},
	Password = #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'password',
	    children = []},
	Digest = #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'digest',
	    children = []},
	Resource = #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'resource',
	    children = []},
	% Make query.
	Query = exmpp_xml:append_children(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'query'},
	    [Username, Password, Digest, Resource]),
	% Make IQ.
	Iq = exmpp_xml:set_attributes(
	    #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'}, [
	    {'type', "result"},
	    {'id',   Id}]),
	exmpp_xml:append_child(Iq, Query).

%% @spec (Username, Password, Resource) -> Auth_Iq
%%     Username = string()
%%     Password = string() | nil()
%%     Resource = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to send authentication informations.
%%
%% The stanza `id' is generated automatically.

legacy_auth_password(Username_S, Password_S, Resource_S) ->
	legacy_auth_password(auth_id(),
	    Username_S, Password_S, Resource_S).

%% @spec (Id, Username, Password, Resource) -> Auth_Iq
%%     Id = string()
%%     Username = string()
%%     Password = string() | nil()
%%     Resource = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to send authentication informations.
%%
%% `Password' is in clear plain text in the stanza.
%%
%% For an anonymous authentication, `Password' may be the empty string.

legacy_auth_password(Id, Username_S, Password_S, Resource_S) ->
	% Fill fields.
	Username = exmpp_xml:set_cdata(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'username'},
	    Username_S),
	Password = exmpp_xml:set_cdata(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'password'},
	    Password_S),
	Resource = exmpp_xml:set_cdata(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'resource'},
	    Resource_S),
	% Make query.
	Query = exmpp_xml:set_children(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'query'},
	    [Username, Password, Resource]),
	% Make IQ.
	Iq = exmpp_xml:set_attributes(
	    #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'}, [
	    {'type', "set"},
	    {'id', Id}]),
	exmpp_xml:append_child(Iq, Query).

%% @spec (Username, Password, Resource) -> Auth_Iq
%%     Username = string()
%%     Password = string()
%%     Resource = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to send authentication informations.
%%
%% The stanza `id' is generated automatically.

legacy_auth_password_digest(Username_S, Password_S, Resource_S) ->
	legacy_auth_password_digest(auth_id(),
	    Username_S, Password_S, Resource_S).

%% @spec (Id, Username, Password, Resource) -> Auth_Iq
%%     Id = string()
%%     Username = string()
%%     Password = string()
%%     Resource = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to send authentication informations.
%%
%% `Password' is encoded as specified in the JEP-078.

legacy_auth_password_digest(Id, Username_S, Password_S, Resource_S) ->
	% Fill fields.
	Username = exmpp_xml:set_cdata(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'username'},
	    Username_S),
	Digest = exmpp_xml:set_cdata(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'digest'},
	    password_digest(Id, Password_S)),
	Resource = exmpp_xml:set_cdata(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'resource'},
	    Resource_S),
	% Make query.
	Query = exmpp_xml:set_children(
	    #xmlnselement{ns = ?NS_JABBER_AUTH, name = 'query'},
	    [Username, Digest, Resource]),
	% Make IQ.
	Iq = exmpp_xml:set_attributes(
	    #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'}, [
	    {'type', "set"},
	    {'id', Id}]),
	exmpp_xml:append_child(Iq, Query).

%% @spec (Id) -> Auth_Iq
%%     Id = string()
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to notify a successfull authentication.

legacy_auth_success(Id) ->
	exmpp_xml:set_attributes(
	#xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq', children = []}, [
	    {'type', "result"},
	    {'id', Id}]).

%% @spec (Id, Reason) -> Auth_Iq
%%     Id = string()
%%     Reason = not_authorized | conflict | not_acceptable
%%     Auth_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to notify a successfull authentication.

legacy_auth_failure(Id, Reason) ->
	% Make <error>.
	Error0 = #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'error'},
	Error = case Reason of
		not_authorized ->
			Child = #xmlnselement{ns = ?NS_XMPP_STANZAS,
			    name = 'not-authorized', children = []},
			exmpp_xml:append_child(
			    exmpp_xml:set_attributes(Error0, [
			    {'code', "401"},
			    {'type', "auth"}]), Child);
		conflict ->
			Child = #xmlnselement{ns = ?NS_XMPP_STANZAS,
			    name = 'conflict', children = []},
			exmpp_xml:append_child(
			    exmpp_xml:set_attributes(Error0, [
			    {'code', "409"},
			    {'type', "cancel"}]), Child);
		not_acceptable ->
			Child = #xmlnselement{ns = ?NS_XMPP_STANZAS,
			    name = 'not-acceptable', children = []},
			exmpp_xml:append_child(
			    exmpp_xml:set_attributes(Error0, [
			    {'code', "406"},
			    {'type', "modify"}]), Child)
	end,
	% Make IQ.
	Iq = exmpp_xml:set_attributes(
	    #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'}, [
	    {'type', "result"},
	    {'id', Id}]),
	exmpp_xml:append_child(Iq, Error).

%% @spec () -> Auth_ID
%%     Auth_ID = string()
%% @doc Generate a random authentication iq ID.
%%
%% This function uses {@link random:uniform/1}. It's up to the caller to
%% seed the generator.

auth_id() ->
	"auth-" ++ integer_to_list(random:uniform(65536 * 65536)).

%% @spec (Id, Passwd) -> Digest
%%     Id = string()
%%     Passwd = string()
%%     Digest = string()
%% @doc Produce a password digest for legacy auth, according to JEP-078.

password_digest(Id, Passwd) ->
	Token = Id ++ Passwd,
	crypto:start(),
	hex(binary_to_list(crypto:sha(Token))).

% --------------------------------------------------------------------
% Internal functions.
% --------------------------------------------------------------------

hex(L) when is_list(L) ->
	lists:flatten([hex(I) || I <- L]);
hex(I) when I > 16#f ->
	[hex0((I band 16#f0) bsr 4), hex0((I band 16#0f))];
hex(I) ->
	[$0, hex0(I)].

hex0(10) -> $a;
hex0(11) -> $b;
hex0(12) -> $c;
hex0(13) -> $d;
hex0(14) -> $e;
hex0(15) -> $f;
hex0(I)  -> $0 +I.