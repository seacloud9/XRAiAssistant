'use client'

import { useState } from 'react'
import { X, Eye, EyeOff, Save, RotateCcw } from 'lucide-react'
import { useAppStore } from '@/store/app-store'
import { getParameterDescription, validateApiKey } from '@/lib/utils'
import toast from 'react-hot-toast'

interface SettingsPanelProps {
  onClose: () => void
}

export function SettingsPanel({ onClose }: SettingsPanelProps) {
  const { settings, updateSettings, providers, libraries, getCurrentProvider, getCurrentModel } = useAppStore()
  const [localSettings, setLocalSettings] = useState(settings)
  const [showApiKeys, setShowApiKeys] = useState<Record<string, boolean>>({})
  const [hasChanges, setHasChanges] = useState(false)

  const currentProvider = providers.find(p => p.id === localSettings.selectedProvider)
  const currentModel = currentProvider?.models.find(m => m.id === localSettings.selectedModel)
  const currentLibrary = libraries.find(l => l.id === localSettings.selectedLibrary)

  const handleSettingChange = (key: keyof typeof settings, value: any) => {
    setLocalSettings(prev => ({ ...prev, [key]: value }))
    setHasChanges(true)
  }

  const handleApiKeyChange = (providerId: string, value: string) => {
    setLocalSettings(prev => ({
      ...prev,
      apiKeys: { ...prev.apiKeys, [providerId]: value }
    }))
    setHasChanges(true)
  }

  const toggleShowApiKey = (providerId: string) => {
    setShowApiKeys(prev => ({ ...prev, [providerId]: !prev[providerId] }))
  }

  const handleSave = () => {
    updateSettings(localSettings)
    setHasChanges(false)
    toast.success('Settings saved successfully!')
    setTimeout(onClose, 1000)
  }

  const handleReset = () => {
    setLocalSettings(settings)
    setHasChanges(false)
    toast.success('Changes reset')
  }

  const parameterDescription = getParameterDescription(localSettings.temperature, localSettings.topP)

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white dark:bg-gray-900 rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
          <div>
            <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Settings</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
              Configure your AI providers and 3D libraries
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div className="overflow-y-auto max-h-[calc(90vh-8rem)]">
          <div className="p-6 space-y-8">
            {/* AI Provider Section */}
            <section>
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-4">
                AI Provider Configuration
              </h3>
              
              {/* Provider Selection */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    AI Provider
                  </label>
                  <select
                    value={localSettings.selectedProvider}
                    onChange={(e) => {
                      handleSettingChange('selectedProvider', e.target.value)
                      // Reset model selection when provider changes
                      const newProvider = providers.find(p => p.id === e.target.value)
                      if (newProvider) {
                        handleSettingChange('selectedModel', newProvider.models[0]?.id || '')
                      }
                    }}
                    className="w-full p-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    {providers.map(provider => (
                      <option key={provider.id} value={provider.id}>
                        {provider.name}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Model Selection */}
                {currentProvider && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Model
                    </label>
                    <select
                      value={localSettings.selectedModel}
                      onChange={(e) => handleSettingChange('selectedModel', e.target.value)}
                      className="w-full p-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      {currentProvider.models.map(model => (
                        <option key={model.id} value={model.id}>
                          {model.name} - {model.pricing}
                        </option>
                      ))}
                    </select>
                    {currentModel && (
                      <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                        {currentModel.description}
                      </p>
                    )}
                  </div>
                )}

                {/* API Keys */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                    API Keys
                  </label>
                  {providers.map(provider => {
                    const validation = validateApiKey(localSettings.apiKeys[provider.id] || '', provider.id)
                    const isCurrentProvider = provider.id === localSettings.selectedProvider
                    return (
                      <div key={provider.id} className="relative">
                        <label className="block text-xs text-gray-600 dark:text-gray-400 mb-1">
                          {provider.name}
                          {isCurrentProvider && (
                            <span className="ml-2 px-2 py-0.5 text-xs bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 rounded">
                              Current
                            </span>
                          )}
                        </label>
                        <div className="relative">
                          <input
                            type={showApiKeys[provider.id] ? 'text' : 'password'}
                            value={localSettings.apiKeys[provider.id] || ''}
                            onChange={(e) => handleApiKeyChange(provider.id, e.target.value)}
                            placeholder={`Enter your ${provider.name} API key`}
                            className={`w-full p-3 pr-12 border rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                              isCurrentProvider && !validation.isValid 
                                ? 'border-red-300 dark:border-red-600' 
                                : 'border-gray-300 dark:border-gray-600'
                            }`}
                          />
                          <button
                            type="button"
                            onClick={() => toggleShowApiKey(provider.id)}
                            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                          >
                            {showApiKeys[provider.id] ? <EyeOff size={16} /> : <Eye size={16} />}
                          </button>
                        </div>
                        {isCurrentProvider && !validation.isValid && (
                          <p className="text-xs text-red-600 dark:text-red-400 mt-1">
                            {validation.message}
                          </p>
                        )}
                        {isCurrentProvider && validation.isValid && (
                          <p className="text-xs text-green-600 dark:text-green-400 mt-1">
                            ✓ {validation.message}
                          </p>
                        )}
                      </div>
                    )
                  })}
                </div>
              </div>
            </section>

            {/* Model Parameters */}
            <section>
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-4">
                Model Parameters
              </h3>
              
              <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 mb-4">
                <div className="text-sm font-medium text-blue-900 dark:text-blue-100 mb-1">
                  Current Configuration
                </div>
                <div className="text-sm text-blue-700 dark:text-blue-200">
                  {parameterDescription}
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Temperature: {localSettings.temperature}
                  </label>
                  <input
                    type="range"
                    min="0"
                    max="2"
                    step="0.1"
                    value={localSettings.temperature}
                    onChange={(e) => handleSettingChange('temperature', parseFloat(e.target.value))}
                    className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer"
                  />
                  <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400 mt-1">
                    <span>Focused (0.0)</span>
                    <span>Creative (2.0)</span>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Top-p: {localSettings.topP}
                  </label>
                  <input
                    type="range"
                    min="0.1"
                    max="1"
                    step="0.1"
                    value={localSettings.topP}
                    onChange={(e) => handleSettingChange('topP', parseFloat(e.target.value))}
                    className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer"
                  />
                  <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400 mt-1">
                    <span>Precise (0.1)</span>
                    <span>Diverse (1.0)</span>
                  </div>
                </div>
              </div>
            </section>

            {/* 3D Library Selection */}
            <section>
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-4">
                3D Library
              </h3>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Selected Library
                </label>
                <select
                  value={localSettings.selectedLibrary}
                  onChange={(e) => handleSettingChange('selectedLibrary', e.target.value)}
                  className="w-full p-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  {libraries.map(library => (
                    <option key={library.id} value={library.id}>
                      {library.name} v{library.version}
                    </option>
                  ))}
                </select>
                {currentLibrary && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
                    {currentLibrary.description}
                  </p>
                )}
              </div>
            </section>

            {/* System Prompt */}
            <section>
              <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-4">
                System Prompt
              </h3>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Custom Instructions (Optional)
                </label>
                <textarea
                  value={localSettings.systemPrompt}
                  onChange={(e) => handleSettingChange('systemPrompt', e.target.value)}
                  placeholder="Add custom instructions for the AI assistant..."
                  rows={4}
                  className="w-full p-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                  This will be added to the library-specific system prompt.
                </p>
              </div>
            </section>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between p-6 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800">
          <div className="text-sm text-gray-600 dark:text-gray-400">
            {hasChanges ? 'You have unsaved changes' : 'All changes saved'}
          </div>
          
          <div className="flex space-x-3">
            {hasChanges && (
              <button
                onClick={handleReset}
                className="flex items-center space-x-2 px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg transition-colors"
              >
                <RotateCcw size={16} />
                <span>Reset</span>
              </button>
            )}
            
            <button
              onClick={handleSave}
              disabled={!hasChanges}
              className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <Save size={16} />
              <span>Save Changes</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}