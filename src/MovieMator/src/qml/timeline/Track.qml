
import QtQuick 2.0
import QtQml.Models 2.1
import 'Track.js' as Logic

Rectangle {
    id: trackRoot
    property alias model: trackModel.model
    property alias rootIndex: trackModel.rootIndex
    property bool isAudio
    property bool isVideo
    property bool isFilter
    property int trackType
    property real timeScale: 1.0
    property bool placeHolderAdded: false
    property bool isCurrentTrack: false
    property bool isLocked: false
    property var selection

    signal clipClicked(var clip, var track)
    signal clipDragged(var clip, int x, int y)
    signal clipDropped(var clip)
    signal clipDraggedToTrack(var clip, int direction)
    signal checkSnap(var clip)

    function redrawWaveforms() {
        for (var i = 0; i < repeater.count; i++)
            repeater.itemAt(i).generateWaveform()
    }

    function snapClip(clip) {
        Logic.snapClip(clip, repeater)
    }

    function snapDrop(clip) {
        Logic.snapDrop(clip, repeater)
    }

    function clipAt(index) {
        return repeater.itemAt(index)
    }

    color: 'transparent'
    width: clipRow.width

    DelegateModel {
        id: trackModel
        Clip {
            clipName: model.name
            clipResource: model.resource
            clipDuration: model.duration
            mltService: model.mlt_service
            inPoint: model.in
            outPoint: model.out
            isBlank: model.blank
            isAudio: model.audio
            isText: model.text
            textThumbnail: model.thumbnail
            isTransition: model.isTransition
            audioLevels: model.audioLevels
            width: model.duration * timeScale
            height: trackRoot.height
            trackIndex: trackRoot.DelegateModel.itemsIndex
            fadeIn: model.fadeIn
            fadeOut: model.fadeOut
            hash: model.hash
            speed: model.speed
            selected: trackRoot.isCurrentTrack && trackRoot.selection.indexOf(index) !== -1
            hasFilter: model.hasFilter


            onClicked: trackRoot.clipClicked(clip, trackRoot);
            onMoved: {
                var fromTrack = clip.originalTrackIndex
                var toTrack = clip.trackIndex
                var clipIndex = clip.originalClipIndex
                var frame = Math.round(clip.x / timeScale)

                // Remove the placeholder inserted in onDraggedToTrack
                if (placeHolderAdded) {
                    placeHolderAdded = false
                    if (fromTrack === toTrack)
                        // XXX This is causing timeline to become undefined making function
                        // call below to fail. This basically results in rejected operation
                        // to the user, but at least it prevents the timeline from becoming
                        // corrupt and out-of-sync with the model.
                        trackModel.items.resolve(clipIndex, clipIndex + 1)
                    else
                        trackModel.items.remove(clipIndex, 1)
                }
                if (!timeline.moveClip(fromTrack, toTrack, clipIndex, frame))
                    clip.x = clip.originalX
            }
            onDragged: {
                if (toolbar.scrub) {
                    root.stopScrolling = false
                    timeline.position = Math.round(clip.x / timeScale)
                }
                // Snap if Alt key is not down.
                if (!(mouse.modifiers & Qt.AltModifier) && toolbar.snap)
                    trackRoot.checkSnap(clip)
                // Prevent dragging left of multitracks origin.
                clip.x = Math.max(0, clip.x)
                var mapped = trackRoot.mapFromItem(clip, mouse.x, mouse.y)
                trackRoot.clipDragged(clip, mapped.x, mapped.y)
            }
            onTrimmingIn: {
                var originalDelta = delta
                if (!(mouse.modifiers & Qt.AltModifier) && toolbar.snap && !toolbar.ripple)
                    delta = Logic.snapTrimIn(clip, delta)
                if (delta != 0) {
                    if (timeline.trimClipIn(trackRoot.DelegateModel.itemsIndex,
                                            clip.DelegateModel.itemsIndex, delta, toolbar.ripple)) {
                        // Show amount trimmed as a time in a "bubble" help.
                        var s = timeline.timecode(Math.abs(clip.originalX))
                        s = '%1%2 = %3'.arg((clip.originalX < 0)? '-' : (clip.originalX > 0)? '+' : '')
                                       .arg(s.substring(3))
                                       .arg(timeline.timecode(clipDuration))
                        bubbleHelp.show(clip.x, trackRoot.y + trackRoot.height, s)
                    } else {
                        clip.originalX -= originalDelta
                    }
                }
            }
            onTrimmedIn: {
                multitrack.notifyClipIn(trackRoot.DelegateModel.itemsIndex, clip.DelegateModel.itemsIndex)
                // Notify out point of clip A changed when trimming to add a transition.
                if (clip.DelegateModel.itemsIndex > 1 && repeater.itemAt(clip.DelegateModel.itemsIndex - 1).isTransition)
                    multitrack.notifyClipOut(trackRoot.DelegateModel.itemsIndex, clip.DelegateModel.itemsIndex - 2)
                bubbleHelp.hide()
            }
            onTrimmingOut: {
                var originalDelta = delta
                if (!(mouse.modifiers & Qt.AltModifier) && toolbar.snap && !toolbar.ripple)
                    delta = Logic.snapTrimOut(clip, delta)
                if (delta != 0) {
                    if (timeline.trimClipOut(trackRoot.DelegateModel.itemsIndex,
                                             clip.DelegateModel.itemsIndex, delta, toolbar.ripple)) {
                        // Show amount trimmed as a time in a "bubble" help.
                        var s = timeline.timecode(Math.abs(clip.originalX))
                        s = '%1%2 = %3'.arg((clip.originalX < 0)? '+' : (clip.originalX > 0)? '-' : '')
                                       .arg(s.substring(3))
                                       .arg(timeline.timecode(clipDuration))
                        bubbleHelp.show(clip.x + clip.width, trackRoot.y + trackRoot.height, s)
                    } else {
                        clip.originalX -= originalDelta
                    }
                }
            }
            onTrimmedOut: {
                multitrack.notifyClipOut(trackRoot.DelegateModel.itemsIndex, clip.DelegateModel.itemsIndex)
                // Notify in point of clip B changed when trimming to add a transition.
                if (clip.DelegateModel.itemsIndex + 2 < repeater.count && repeater.itemAt(clip.DelegateModel.itemsIndex + 1).isTransition)
                    multitrack.notifyClipIn(trackRoot.DelegateModel.itemsIndex, clip.DelegateModel.itemsIndex + 2)
                bubbleHelp.hide()
            }
            onDraggedToTrack: {
                if (!placeHolderAdded) {
                    placeHolderAdded = true
                    trackModel.items.insert(clip.DelegateModel.itemsIndex, {
                        'name': '',
                        'resource': '',
                        'duration': clip.clipDuration,
                        'mlt_service': '<producer',
                        'in': 0,
                        'out': clip.clipDuration - 1,
                        'blank': true,
                        'audio': false,
                        'isTransition': false,
                        'fadeIn': 0,
                        'fadeOut': 0
                    })
                }
            }
            onClipdropped: placeHolderAdded = false

            Component.onCompleted: {
                moved.connect(trackRoot.clipDropped)
                clipdropped.connect(trackRoot.clipDropped)
                draggedToTrack.connect(trackRoot.clipDraggedToTrack)
            }
        }
    }

    Row {
        id: clipRow
        Repeater { id: repeater; model: trackModel }
    }
}
