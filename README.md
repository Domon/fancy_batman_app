# Fancy App

Batman, Rails, Bootstrap app, plus real time updates via Pusher.

## Install

    bundle
    rake db:reboot # sets everything up

## Configuration

You'll need to setup an account on Pusher and have the right environment variables specified.  Create .env

    PUSHER_APPID=12345
    PUSHER_KEY=1234567890
    PUSHER_SECRET=1234567890

If you use pow, also create a .powenv

    export $(cat .env)

## Batman Components

There are two ways real time updates get to Batman:  Batman Pusher (dubbed multiplayer) and BatchedRailsStorage (single player)
* BatmanPusher - connects the browser to Pusher for real time updates
* BatchedRailsStorage - a storage module that takes the batch included inline with the request and feeds it to ModelUpdater
* ModelUpdater - parses the real time updates from BatmanPusher and updates the Batman models, which then update the view bindings

## Rails Components

* ApplicationController hooks - for starting DirtyTracker, overriding render to include a batch inline (single player), and calling the publish method of DirtyTracker (multiplayer)
* DirtyTracker - this is a Rails-side component that keeps track of changes on all the models you designate.  It has some logic to package the changes up in a way the ModelUpdater understands
* PusherWorker/PusherBatchWorker - a duo that can be used for asynchronous transmission of updates
