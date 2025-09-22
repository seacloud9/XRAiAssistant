// Test script to debug React Three Fiber component issues
console.log('🔍 COMPONENT DEBUG TEST:');

// Test basic library existence
console.log('React:', typeof window.React);
console.log('ReactDOM:', typeof window.ReactDOM);
console.log('THREE:', typeof window.THREE);

// Test React Three Fiber object
console.log('ReactThreeFiber exists:', !!window.ReactThreeFiber);
if (window.ReactThreeFiber) {
    console.log('ReactThreeFiber.Canvas:', typeof window.ReactThreeFiber.Canvas);
    console.log('ReactThreeFiber.useFrame:', typeof window.ReactThreeFiber.useFrame);
    console.log('ReactThreeFiber.useThree:', typeof window.ReactThreeFiber.useThree);
    console.log('ReactThreeFiber.useLoader:', typeof window.ReactThreeFiber.useLoader);
}

// Test Drei object
console.log('Drei exists:', !!window.Drei);
if (window.Drei) {
    console.log('Drei.OrbitControls:', typeof window.Drei.OrbitControls);
    console.log('Drei.Box:', typeof window.Drei.Box);
    console.log('Drei.Sphere:', typeof window.Drei.Sphere);
    console.log('Drei.Environment:', typeof window.Drei.Environment);
    console.log('Object.keys(Drei):', Object.keys(window.Drei));
}

// Test boolean conversion (this is what the component checker likely uses)
console.log('Boolean tests:');
console.log('!!window.Drei.OrbitControls:', !!window.Drei?.OrbitControls);
console.log('!!window.Drei.Box:', !!window.Drei?.Box);
console.log('!!window.Drei.Sphere:', !!window.Drei?.Sphere);
console.log('!!window.Drei.Environment:', !!window.Drei?.Environment);

// Test function call (to see if components are actually callable)
try {
    if (window.React && window.Drei && window.Drei.Box) {
        console.log('Testing Box component creation...');
        const testBox = window.Drei.Box({ args: [1, 1, 1], color: 0x00ff00 });
        console.log('Box component created:', testBox);
    }
} catch (error) {
    console.error('Error testing Box component:', error);
}