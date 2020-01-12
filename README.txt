vstrework0207 this is a big technically, but technically, we have the full behavior done. :)))))))))))))))))))))))))))))
has:
pressable play button (or mouse click)
mostly complete data structure
playable and sequenceable pitches WITH their envelopes
new draw loop switch function that will turn into the primary state machine for the exhibit.


goals:
remove delay on sound starting
start adding prettier graphics
find source of jitters and destroy it
make prettier versions of our base envelopes
adding audioreactive lines


on the horizon:
finally dialing in reactivision hardware positioning/settings

mild concern:
concurrentModificationException-
this bad boy could be trouble: 
	I think the source has got to be with multithreading. tuioFunctions and lineRender are both doing work on the baseDistEnvMap
	I don't think the updates/adds are causing the problems, I think it is the removeTuioObj() function. If an object is removed
	in the tiny space of time where lineRender is doing work with baseDistEnvMap.values() it throws the exception. Optimistically,
	I'd like to believe that this won't be able to happen once the environment is stabilized but we really can't be sure until then.
	If that's not the case, we might be in a little trouble. I'll have to look for an even tighter way to control the TUIOclient or
	change my data structure.