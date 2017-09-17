# CommentsBox

Type = require 'Type'
{ flow } = require 'Flow'
{ colors } = require 'Colors'
{ Icon } = require 'Icon'
{ Comment } = require 'Comment'
{ TextField } = require 'TextField'
{ CommentCard } = require 'CommentCard'
{ database } = require 'Database'

user = database.user

new Laye

class exports.CommentsBox extends Layer
	constructor: (options = {}) ->
		
		@content = options.parent.content
		@_commentsHeight = 0
		@_isOpen = false
		@_vote = user.votes[@content.uid]

		super _.defaults options,
			height: 64
			width: options.parent.width
			backgroundColor: 'rgba(0,0,0,0)'
			animationOptions: { time: .15 }
			shadowY: -1
			shadowColor: colors.pale
	
		# container for comments
			
		@commentsContainer = new Layer
			name: 'Comments Container'
			parent: @
			width: @width
			height: 64
			backgroundColor: null
		
		# controls
		
		@controls = new Layer
			name: 'Controls'
			parent: @
			width: @width
			height: 48
			backgroundColor: null
			animationOptions: @animationOptions
		
		new La

		# add a comment
		@addAComment = new Type.Caption
			parent: @controls
			name: 'Add a comment'
			text: 'Add a comment'
			x: 16, y: Align.center
			color: colors.med
		
		# view more comments
		
		
		@moreComments = new Layer
			name: 'More Comments'
			parent: @controls
			height: @controls.height
			width: 240
			backgroundColor: null

		@moreCommentsCount = new Type.Caption
			name: 'More Count'
			parent: @moreComments
			color: colors.bright
			x: 16
			y: Align.center
			text: "View {commentCount} more comment{plural}"
			
		@moreComments.onTap @showFullComments
		
		# view fewer comments
		
		@fewerComments = new Layer
			name: 'Fewer Comments'
			parent: @controls
			height: @controls.height
			width: 240
			backgroundColor: null
			visible: false
	
		@fewerCommentsLabel = new Type.Caption
			name: 'Fewer Count'
			parent: @fewerComments
			color: colors.bright
			x: 16
			y: Align.center
			text: "View fewer comments"
		
		@fewerComments.onTap @showPartialComments
		
		# voting
		
		@upIcon = new Icon
			name: 'Up'
			parent: @controls
			x: Align.right(-14)
			y: Align.center
			color: colors.dim
			toggle: true
			icon: 'arrow-up-bold-circle-outline'
			onColor: colors.tint
			action: => @vote = 1
		
		@downIcon = new Icon
			name: 'Down'
			parent: @controls
			x: Align.right(-46)
			y: Align.center
			color: colors.dim
			toggle: true
			icon: 'arrow-down-bold-circle-outline'
			onColor: colors.tint
			action: => @vote = -1
			
		@voteLabel = new Type.Caption
			name: 'Vote Label'
			parent: @controls
			x: Align.right(-78), y: Align.center
			width: 128
			fontWeight: 600
			color: colors.dim
			textAlign: 'right'
			text: "{plus}{voteCount}"
		
		@voteLabel.template = 
			plus: if @content.score > 0 then '+' else ''
			voteCount: @content.score

		# comment input box

		@commentInputBox = new Layer
			name: 'Input Box'
			parent: @
			y: @controls.maxY
			width: @width
			height: 48
			backgroundColor: null
			animationOptions: @animationOptions
		
		@input = new TextField
			name: 'Input'
			parent: @commentInputBox
			view: @parent.view
			x: 16
			width: @width - 32
		
		@input.on "submit", (value, layer) => 
			if value?.length > 0
				@createComment()

		@input.view = @view

		@sendButton = new Type.Caption
			parent: @
			x: Align.right(32)
			y: @controls.maxY
			padding: {top: 8, bottom: 8, left: 16, right: 16}
			color: colors.tint
			fontWeight: 600
			text: 'Send'
			opacity: 0
			animationOptions: @animationOptions
		
		@sendButton.onTap => @input.submit()

		sendButton = @sendButton
		_baseSendButtonX = @sendButton.x
		
		@input.showFocused = ->
			return if @disabled
			
			if @focused
				flow.header.open()
				flow.openKeyboard()
				
				@animate
					width: @_baseWidth - 40
					borderColor: colors.dim
				sendButton.animate
					x: _baseSendButtonX - 32
					opacity: 1
				
			else
				@animate
					width: @_baseWidth
					borderColor: colors.pale
				sendButton.animate
					x: _baseSendButtonX
					opacity: 0
				flow.closeKeyboard()

		@refresh()
	
	createComment: ->
		comment = new Comment
			author: user
			content: @input.value
		
		@input.clearValue()
		@input.focused = false
		
		@content.comments.push(comment)
		if @content.comments.length > 2 then @showFullComments() 
		else @showPartialComments()
	
	getVotes: -> return @_votes
	
	showVotes: ->
		vote = user.votes[@content.uid]
		
		for icon in [@upIcon, @downIcon]
			icon.isOn = colors.false
		
		switch vote
			when 1 then @upIcon.isOn = true
			when -1 then @downIcon.isOn = true
		
		@voteLabel.template = 
			plus: if @content.score > 0 then '+' else ''
			voteCount: @content.score
	
	showPartialComments: =>
		comment.destroy() for comment in @commentsContainer.children
	
		@populateComments( full = false )
		@_commentsHeight = _.last(@commentsContainer.children)?.maxY ? 0
		@_commentsHeight = _.clamp(@_commentsHeight, 0, 256)
		
		@moveLayers()
		
		@isOpen = false
	
	showFullComments: =>
		comment.destroy() for comment in @commentsContainer.children
		
		@populateComments( full = true )
		@_commentsHeight = _.last(@commentsContainer.children)?.maxY
		
		@moveLayers()
		
		@isOpen = true
	
	moveLayers: =>
		@commentsContainer.height = @_commentsHeight
		@controls?.animate { y: @_commentsHeight }
		@commentInputBox?.animate { y: @_commentsHeight + 48 }
		@sendButton?.animate { y: @_commentsHeight + 48 }
		@animate { height: @_commentsHeight + 96 }
	
	populateComments: (full = false) ->
		startY = 16
		
		sortedComments = _.sortBy(@content.comments, 'date')
		selectedComments = if full then sortedComments 
		else sortedComments[0...2]
		
		for comment in selectedComments
			newComment = new CommentCard
				parent: @commentsContainer
				x: 16, y: startY
				width: @width - 16
				content: comment
			
			startY += newComment.height + 16
					
		@_commentsHeight = _.last(@commentsContainer.children)?.maxY
		@setRemainingTag()
	
	setRemainingTag: =>
		remaining = @content.comments.length - 
			@commentsContainer.children.length
		
		@moreCommentsCount.template =
			commentCount: remaining
			plural: if remaining > 1 then 's' else ''
			
		for layer in [@moreComments]
			layer.visible = remaining > 0
			
		@addAComment.visible = @content.comments.length < 3
	
	showState: -> if @isOpen then @open() else @close()
	
	open: ->
		@moreComments.visible = false
		@fewerComments.visible = true
	
	close: ->
		@moreComments.visible = true
		@fewerComments.visible = false
	
	refresh: ->
		@height = @commentInputBox.maxY
		@showPartialComments()
		@showVotes()
	
	@define 'isOpen',
		get: -> return @_isOpen
		set: (bool) ->
			return if bool is @_isOpen
			@_isOpen = bool
			@emit "change:isOpen", bool, @
	
			@showState()
			
	@define 'vote',
		get: -> return @_vote
		set: (vote) ->
			currentVote = user.votes[@content.uid]
			if vote is currentVote then vote = 0
			
			@content.score -= currentVote # clear existing vote
			currentVote = vote
			@content.score += currentVote # add new vote
		
			user.votes[@content.uid] = currentVote 
			
			@showVotes()