{Cache} = require './cache'
{extend} = require './helpers'

Serenade =
  VERSION: '0.1.3'
  _views: {}
  _controllers: {}
  _formats: {}

  document: window?.document

  view: (nameOrTemplate, template) ->
    {View} = require('./view')
    if template
      @_views[nameOrTemplate] = new View(nameOrTemplate, template)
    else
      new View(undefined, nameOrTemplate)

  render: (name, model, controller) ->
    @_views[name].render(model, controller)

  controller: (name, klass) ->
    @_controllers[name] = klass
  controllerFor: (name, model) ->
    new (@_controllers[name])(model) if @_controllers[name]
  registerFormat: (name, fun) ->
    @_formats[name] = fun
  clearIdentityMap: -> Cache._identityMap = {}
  clearLocalStorage: -> Cache._storage.clear()
  clearCache: ->
    Serenade.clearIdentityMap()
    Serenade.clearLocalStorage()
  unregisterAll: ->
    Serenade._views = {}
    Serenade._controllers = {}
    Serenade._formats = {}
  bindEvent: (element, event, callback) ->
    if typeof element.addEventListener is 'function'
      element.addEventListener(event, callback, false)
    else
      element.attachEvent('on' + event, callback)
  useJQuery: ->
    @bindEvent = (element, event, callback) ->
      jQuery(element).bind(event, callback)
  extend: extend

  Events: require('./events').Events
  Collection: require('./collection').Collection
  Helpers: {}

exports.Serenade = Serenade

# Express.js support
exports.compile = ->
  document = require("jsdom").jsdom(null, null, {})
  fs = require("fs")
  window = document.createWindow()
  Serenade.document = document

  (env) ->
    model = env.model
    viewName = env.filename.split('/').reverse()[0].replace(/\.serenade$/, '')
    Serenade.view(viewName, fs.readFileSync(env.filename).toString())
    element = Serenade.render(viewName, model, {})
    document.body.appendChild(element)
    html = document.body.innerHTML
    html = "<!DOCTYPE html>\n" + html unless env.doctype is false
    html
