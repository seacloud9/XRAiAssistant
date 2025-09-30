'use client'

import { MessageCircle, Code, Play } from 'lucide-react'
import { useAppStore } from '@/store/app-store'
import { cn } from '@/lib/utils'

export function BottomNavigation() {
  const { currentView, setCurrentView } = useAppStore()

  const tabs = [
    {
      id: 'chat' as const,
      label: 'Chat',
      icon: MessageCircle,
      description: 'AI Conversation'
    },
    {
      id: 'playground' as const,
      label: 'Playground',
      icon: Code,
      description: '3D Scene Editor'
    }
  ]

  return (
    <nav className="flex bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700">
      {tabs.map((tab) => {
        const Icon = tab.icon
        const isActive = currentView === tab.id
        
        return (
          <button
            key={tab.id}
            onClick={() => setCurrentView(tab.id)}
            className={cn(
              "flex-1 flex flex-col items-center justify-center px-3 py-3 transition-colors",
              isActive
                ? "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20"
                : "text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-800"
            )}
          >
            <Icon size={20} className="mb-1" />
            <span className="text-xs font-medium">{tab.label}</span>
            <span className="text-[10px] text-gray-500 dark:text-gray-400 mt-0.5">
              {tab.description}
            </span>
          </button>
        )
      })}
    </nav>
  )
}