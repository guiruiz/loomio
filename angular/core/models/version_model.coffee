angular.module('loomioApp').factory 'VersionModel', (BaseModel) ->
  class VersionModel extends BaseModel
    @singular: 'version'
    @plural: 'versions'
    @indices: ['discussionId']

    relationships: ->
      @belongsTo 'discussion'
      @belongsTo 'comment'
      @belongsTo 'proposal'
      @belongsTo 'author', from: 'users', by: 'whodunnit'

    editedAttributeNames: ->
      _.filter _.keys(@changes).sort(), (key) ->
        _.include ['title', 'name', 'description', 'closing_at'], key

    attributeEdited: (name) ->
       _.include(_.keys(@changes), name)

    isCurrent: ->
      @id == _.last(@discussion().versions())['id']

    isOriginal: ->
      @id == _.first(@discussion().versions())['id']

    authorOrEditorName: ->
      if @isOriginal()
        @discussion().authorName()
      else
        @author().name
