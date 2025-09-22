const { buildCode, clearCache, getStats, handleMessage } = require('./build-worker');

// Test suite for Node.js build worker
async function runTests() {
    console.log('🧪 Running Node.js Build Worker Tests...\n');
    
    // Test 1: Simple React Three Fiber build
    console.log('Test 1: React Three Fiber build');
    try {
        const request = {
            framework: 'reactThreeFiber',
            entry: '/src/index.tsx',
            files: {
                '/src/index.tsx': `
import React from 'react'
import { createRoot } from 'react-dom/client'
import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'

function Scene() {
  return (
    <>
      <ambientLight intensity={0.6} />
      <directionalLight position={[2, 2, 2]} />
      <mesh>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="hotpink" />
      </mesh>
      <OrbitControls />
    </>
  )
}

function App() {
  return (
    <Canvas style={{ width: '100%', height: '100%' }}>
      <Scene />
    </Canvas>
  )
}

const root = createRoot(document.getElementById('root')!)
root.render(<App />)
                `
            },
            defines: {
                'process.env.NODE_ENV': '"production"'
            },
            minify: false
        };
        
        const result = await buildCode(request);
        console.log(`✅ Build status: ${result.status}`);
        console.log(`   Duration: ${result.durationMs}ms`);
        console.log(`   Bundle size: ${(result.bytes / 1024).toFixed(1)}KB`);
        console.log(`   Warnings: ${result.warnings.length}`);
        console.log(`   Errors: ${result.errors.length}`);
        console.log(`   From cache: ${result.fromCache || false}`);
        
        if (result.bundleCode && result.bundleCode.length > 0) {
            console.log(`   Bundle preview: ${result.bundleCode.substring(0, 100)}...`);
        }
        
    } catch (error) {
        console.error(`❌ Test 1 failed: ${error.message}`);
    }
    
    console.log('\n' + '='.repeat(60) + '\n');
    
    // Test 2: Reactylon build
    console.log('Test 2: Reactylon build');
    try {
        const request = {
            framework: 'reactylon',
            entry: '/src/index.tsx',
            files: {
                '/src/index.tsx': `
import React from 'react'
import { createRoot } from 'react-dom/client'
import {
  Engine, Scene, ArcRotateCamera, HemisphericLight,
  Box, StandardMaterial
} from 'reactylon'

function XRScene() {
  return (
    <Engine antialias adaptToDeviceRatio canvasId="canvas">
      <Scene clearColor="#2c2c54">
        <ArcRotateCamera 
          target={[0, 0, 0]} 
          alpha={Math.PI / 4} 
          beta={Math.PI / 3} 
          radius={8} 
        />
        <HemisphericLight direction={[0, 1, 0]} intensity={0.9} />
        
        <Box name="cube" size={1.5} position={[0, 1, 0]}>
          <StandardMaterial diffuseColor="#ff6b6b" />
        </Box>
      </Scene>
    </Engine>
  )
}

const root = createRoot(document.getElementById('root')!)
root.render(<XRScene />)
                `
            },
            defines: {
                'process.env.NODE_ENV': '"production"'
            },
            minify: false
        };
        
        const result = await buildCode(request);
        console.log(`✅ Build status: ${result.status}`);
        console.log(`   Duration: ${result.durationMs}ms`);
        console.log(`   Bundle size: ${(result.bytes / 1024).toFixed(1)}KB`);
        console.log(`   Warnings: ${result.warnings.length}`);
        console.log(`   Errors: ${result.errors.length}`);
        
    } catch (error) {
        console.error(`❌ Test 2 failed: ${error.message}`);
    }
    
    console.log('\n' + '='.repeat(60) + '\n');
    
    // Test 3: Cache functionality
    console.log('Test 3: Cache test (build same code twice)');
    try {
        const request = {
            framework: 'reactThreeFiber',
            entry: '/src/index.tsx',
            files: {
                '/src/index.tsx': 'console.log("Simple test");'
            },
            defines: {},
            minify: false
        };
        
        // First build
        const result1 = await buildCode(request);
        console.log(`First build: ${result1.durationMs}ms (cache: ${result1.fromCache || false})`);
        
        // Second build (should be cached)
        const result2 = await buildCode(request);
        console.log(`Second build: ${result2.durationMs}ms (cache: ${result2.fromCache || false})`);
        
        if (result2.fromCache) {
            console.log('✅ Cache working correctly');
        } else {
            console.log('⚠️ Cache not working as expected');
        }
        
    } catch (error) {
        console.error(`❌ Test 3 failed: ${error.message}`);
    }
    
    console.log('\n' + '='.repeat(60) + '\n');
    
    // Test 4: Error handling
    console.log('Test 4: Error handling test');
    try {
        const request = {
            framework: 'reactThreeFiber',
            entry: '/src/index.tsx',
            files: {
                '/src/index.tsx': `
import React from 'react'
import { invalid syntax here }
                `
            },
            defines: {},
            minify: false
        };
        
        const result = await buildCode(request);
        console.log(`Build status: ${result.status}`);
        console.log(`Errors: ${result.errors.length}`);
        
        if (result.errors.length > 0) {
            console.log('✅ Error handling working correctly');
            console.log(`   First error: ${result.errors[0]}`);
        } else {
            console.log('❌ Expected errors but got none');
        }
        
    } catch (error) {
        console.error(`❌ Test 4 failed: ${error.message}`);
    }
    
    console.log('\n' + '='.repeat(60) + '\n');
    
    // Test 5: Statistics
    console.log('Test 5: Statistics test');
    try {
        const stats = getStats();
        console.log('📊 Build Statistics:');
        console.log(`   Total builds: ${stats.totalBuilds}`);
        console.log(`   Cache hits: ${stats.cacheHits}`);
        console.log(`   Average build time: ${stats.averageBuildTime.toFixed(1)}ms`);
        console.log(`   Last build time: ${stats.lastBuildTime}ms`);
        console.log(`   Cache size: ${stats.cacheSize} entries`);
        console.log(`   Uptime: ${stats.uptime.toFixed(1)}s`);
        
    } catch (error) {
        console.error(`❌ Test 5 failed: ${error.message}`);
    }
    
    console.log('\n' + '='.repeat(60) + '\n');
    console.log('🏁 Tests completed!');
}

// Run tests if this file is executed directly
if (require.main === module) {
    runTests().catch(console.error);
}

module.exports = { runTests };