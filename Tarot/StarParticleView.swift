//
//  StarParticleView.swift
//  Tarot
//
//  Created by Rosie on 12/14/25.
//

import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let velocityX: CGFloat
    let velocityY: CGFloat
    var opacity: Double = 1.0
    var scale: Double = 0.15
    var rotation: Double = 0
}

// MARK: - Particle Effect View
struct ParticleEffectView: View {
    let startPosition: CGPoint
    let particleCount: Int = Int.random(in: 4...9)
    @State private var particles: [Particle] = []
    @State private var animationProgress: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image("star") // Replace "star" with your image asset name
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.yellow)
                    .frame(width: 10, height: 10)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.x, y: particle.y)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    func generateParticles() {
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 2...10)
            
            return Particle(
                x: startPosition.x,
                y: startPosition.y,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    func animateParticles() {
        let duration: Double = 0.8
        let updateInterval: Double = 1.0 / 60.0 // 60 FPS
        
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            animationProgress += updateInterval / duration
            
            if animationProgress >= 1.0 {
                timer.invalidate()
                return
            }
            
            particles = particles.map { particle in
                var p = particle
                p.x += particle.velocityX
                p.y += particle.velocityY
                p.opacity = max(0, 1.0 - animationProgress)
                // Scale from 0.15 to 1.2 (grows larger)
                p.scale = 0.15 + (animationProgress * 8.05)
                p.rotation += 6
                return p
            }
        }
    }
}
