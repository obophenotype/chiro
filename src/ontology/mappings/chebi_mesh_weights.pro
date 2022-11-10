% xrefs
weight(1.0, [predicate_id='owl:equivalentClass', subject_match_field='oio:hasDbXref', object_match_field='oio:hasDbXref']).

weight(2, [predicate_id='owl:equivalentClass', any_match_field='dc:identifier']).
weight(2, [predicate_id='owl:equivalentClass', any_match_field='schema:url']).

weight(3, [predicate_id='owl:equivalentClass', any_match_field='rdfs:label']).
weight(3, [predicate_id='owl:equivalentClass', any_match_field='oio:hasExactSynonym']).
weight(3, [predicate_id='owl:equivalentClass', any_match_field='skos:exactMatch']).
weight(2, [predicate_id='owl:equivalentClass', any_match_field='oio:hasRelatedSynonym']).

weight(-2, [predicate_id='owl:equivalentClass', any_match_field='oio:hasNarrowSynonym']).
weight(-2, [predicate_id='owl:equivalentClass', any_match_field='oio:hasBroadSynonym']).

% lexical is lower, stemmming even lower
weight(-1.0, [predicate_id='owl:equivalentClass', match_type=['Lexical','Stemming']]).
weight(-0.5, [predicate_id='owl:equivalentClass', match_type=['Lexical']]).

weight(-1, [match_string=S]) :-  atom_length(S,3).
weight(-2, [match_string=S]) :-  atom_length(S,2).
weight(-3, [match_string=S]) :-  atom_length(S,1).
weight(-99, [match_string=S]) :-  atom_length(S,0).


