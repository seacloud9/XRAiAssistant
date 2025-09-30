'use client'

import { useState } from 'react'
import { ChatInterface } from '@/components/chat/chat-interface'
import { PlaygroundView } from '@/components/playground/playground-view'
import { SettingsPanel } from '@/components/settings/settings-panel'
import { Header } from '@/components/layout/header'
import { BottomNavigation } from '@/components/layout/bottom-navigation'
import { useAppStore } from '@/store/app-store'

export default function Home() {
  const { currentView } = useAppStore()
  const [showSettings, setShowSettings] = useState(false)

  const renderCurrentView = () => {
    switch (currentView) {
      case 'chat':
        return <ChatInterface />
      case 'playground':
        return <PlaygroundView />
      default:
        return <ChatInterface />
    }
  }

  return (
    <div className="flex flex-col h-screen bg-white dark:bg-gray-900">
      <Header onOpenSettings={() => setShowSettings(true)} />
      
      <main className="flex-1 overflow-hidden">
        {renderCurrentView()}
      </main>
      
      <BottomNavigation />
      
      {showSettings && (
        <SettingsPanel onClose={() => setShowSettings(false)} />
      )}
    </div>
  )
}