"
I am a scene graph renderer that uses the BitBlt canvas for rendering.
"
Class {
	#name : #FormSGCanvasRenderer,
	#superclass : #FormSGRenderer,
	#instVars : [
		'canvas',
		'currentTransform'
	],
	#category : #'FormSceneGraph-Renderer'
}

{ #category : #rendering }
FormSGCanvasRenderer class >> render: node on: canvas [
	^ self new render: node on: canvas
]

{ #category : #rendering }
FormSGCanvasRenderer class >> render: node withTransform: initialTransform on: canvas [
	^ self new render: node withTransform: initialTransform on: canvas
]

{ #category : #rendering }
FormSGCanvasRenderer >> render: node on: aCanvas [
	self render: node withTransform: FormSGAffineTransform identity on: aCanvas
]

{ #category : #rendering }
FormSGCanvasRenderer >> render: node withTransform: initialTransform on: aCanvas [
	canvas := aCanvas.
	currentTransform := initialTransform.
	self visitNode: node.
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitBorderNode: node [
	node color isTransparent ifTrue: [ ^ self ].
	
	node borderRectanglesDo: [ :rect |
		canvas fillRectangle: rect color: node color
	].
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitCachedSubScene: node [
	| form |
	node rectangle ifNil: [ ^ self ].
	form := node validCachedForm.
	form ifNil: [ ^ self ].
	
	canvas translucentImage: form at: node rectangle origin
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitClipNode: node [
	node child isTransformNode ifTrue: [
		canvas transformBy: node child transform asDisplayTransform clippingTo: node rectangle during: [:clippedCanvas |
			| oldCanvas |
			oldCanvas := canvas.
			[ 
				canvas := clippedCanvas.
				self visitNode: node child child
			] ensure: [ canvas := oldCanvas ]
		].
		^ self
	].

	canvas clipBy: node rectangle during: [:clippedCanvas |
		| oldCanvas |
		oldCanvas := canvas.
		[ 
			canvas := clippedCanvas.
			self visitNode: node child
		] ensure: [ canvas := oldCanvas ]
	]
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitColorNode: node [
	canvas fillRectangle: node rectangle color: node color
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitContainerNode: node [
	self visitNodes: node children
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitNullNode: node [
	"Nothing required"
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitTextNode: node [
	canvas drawString: node string from: node firstIndex to: node lastIndex
		in: node rectangle
		font: node font color: node color
		underline: node underline underlineColor: node underlineColor
		strikethrough: node strikethrough strikethroughColor: node strikethroughColor
		kern: node kern

]

{ #category : #visiting }
FormSGCanvasRenderer >> visitTextureNode: node [
	node isFullyOpaque ifTrue: [
		canvas drawImage: node form at: node rectangle origin
	] ifFalse: [ 
		canvas translucentImage: node form at: node rectangle origin
	].


]

{ #category : #visiting }
FormSGCanvasRenderer >> visitTransformNode: node [
	canvas transformBy: node child transform asDisplayTransform clippingTo: node boundingBox during: [:transformedCanvas |
		| oldCanvas |
		oldCanvas := canvas.
		[ 
			canvas := transformedCanvas.
			self visitNode: node child
		] ensure: [ canvas := oldCanvas ]
	]
]

{ #category : #visiting }
FormSGCanvasRenderer >> visitTranslationNode: node [
	canvas translateBy: node translation during: [:translatedCanvas |
		| oldCanvas |
		oldCanvas := canvas.
		[ 
			canvas := translatedCanvas.
			self visitNode: node child
		] ensure: [ canvas := oldCanvas ]
	]
]
