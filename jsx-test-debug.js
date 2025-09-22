// Test script to debug JSX transformation issues
console.log('🔍 JSX TRANSFORMATION DEBUG TEST:');

// Test 1: Simple JSX code that should fail without transformation
const jsxCode = `
import React from 'react';
import { Canvas } from '@react-three/fiber';

function App() {
  return (
    <Canvas>
      <mesh>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="hotpink" />
      </mesh>
    </Canvas>
  );
}
`;

console.log('Original JSX code:');
console.log(jsxCode);

// Test 2: Apply the current import transformation
let transformedCode = jsxCode
    .replace(/import\s+React[^'"]*from\s+['"]react['"];?\s*/g, 'const React = window.React;\n')
    .replace(/import\s+\{([^}]+)\}\s+from\s+['"]react['"];?\s*/g, 'const {$1} = window.React;\n')
    .replace(/import\s+\{([^}]+)\}\s+from\s+['"]react-dom\/client['"];?\s*/g, 'const {$1} = window.ReactDOM;\n')
    .replace(/import\s+\{([^}]+)\}\s+from\s+['"]@react-three\/fiber['"];?\s*/g, 'const {$1} = window.ReactThreeFiber;\n')
    .replace(/import\s+\{([^}]+)\}\s+from\s+['"]@react-three\/drei['"];?\s*/g, 'const {$1} = window.Drei;\n')
    .replace(/import\s+\*\s+as\s+THREE\s+from\s+['"]three['"];?\s*/g, 'const THREE = window.THREE;\n')
    .replace(/import\s+THREE\s+from\s+['"]three['"];?\s*/g, 'const THREE = window.THREE;\n');

console.log('\nAfter import transformation:');
console.log(transformedCode);

console.log('\n🚨 ISSUE IDENTIFIED:');
console.log('The JSX syntax (<Canvas>, <mesh>, etc.) is NOT being transformed!');
console.log('This will cause "Script error" because browsers cannot parse JSX natively.');
console.log('\n💡 SOLUTION NEEDED:');
console.log('1. Add JSX to React.createElement() transformation');
console.log('2. OR: Switch to React.createElement() syntax in the default code');
console.log('3. OR: Use a JSX transformer like Babel in the browser');