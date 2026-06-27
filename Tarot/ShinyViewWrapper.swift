//
//  ShinyViewWrapper.swift
//  Tarot
//
//  Created by Rosie on 6/27/26.
//

import SwiftUI
import Shiny

struct ShinyViewWrapper: UIViewRepresentable {
    var colors: [UIColor] = [
        // Seamless violet edge
        UIColor(red: 0.35, green: 0.12, blue: 0.85, alpha: 1.00), // deep violet

        // Main purple/blue shift
        UIColor(red: 0.55, green: 0.25, blue: 1.00, alpha: 1.00), // electric purple
        UIColor(red: 0.28, green: 0.45, blue: 1.00, alpha: 1.00), // royal blue
        UIColor(red: 0.15, green: 0.78, blue: 1.00, alpha: 1.00), // cyan flash

        // Rainbow iridescent accents
        UIColor(red: 0.30, green: 1.00, blue: 0.82, alpha: 1.00), // aqua/mint
        UIColor(red: 0.95, green: 0.95, blue: 0.45, alpha: 1.00), // soft yellow glint
        UIColor(red: 1.00, green: 0.45, blue: 0.75, alpha: 1.00), // rose pink

        // Bright central shine burst
        UIColor.white.withAlphaComponent(1.00),

        // Mirror back out for a smoother, nacreous loop
        UIColor(red: 1.00, green: 0.45, blue: 0.75, alpha: 1.00), // rose pink
        UIColor(red: 0.95, green: 0.95, blue: 0.45, alpha: 1.00), // soft yellow glint
        UIColor(red: 0.30, green: 1.00, blue: 0.82, alpha: 1.00), // aqua/mint

        // Return to the main blue/purple family
        UIColor(red: 0.15, green: 0.78, blue: 1.00, alpha: 1.00), // cyan flash
        UIColor(red: 0.28, green: 0.45, blue: 1.00, alpha: 1.00), // royal blue
        UIColor(red: 0.55, green: 0.25, blue: 1.00, alpha: 1.00), // electric purple

        // Same as first color for seamless transition
        UIColor(red: 0.35, green: 0.12, blue: 0.85, alpha: 1.00)  // deep violet
    ]
    
    let gradientLocations: [CGFloat] = [
        0.00,
        0.08,
        0.16,
        0.24,
        0.31,
        0.38,
        0.45,

        // tight center burst
        0.50,

        0.55,
        0.62,
        0.69,
        0.76,
        0.84,
        0.92,
        1.00
    ]

    func makeUIView(context: Context) -> ShinyView {
        let shinyView = ShinyView(frame: CGRect(x: 0, y: 0, width: 180, height: 300))
        shinyView.colors = colors
        shinyView.locations = gradientLocations
        shinyView.scale = 2.4
        shinyView.backgroundColor = .clear
        return shinyView
    }

    func updateUIView(_ uiView: ShinyView, context: Context) {
        uiView.colors = colors
        uiView.locations = gradientLocations

        DispatchQueue.main.async {
            if uiView.bounds.width > 0,
               uiView.bounds.height > 0,
               uiView.window != nil {
                uiView.startUpdates()
            }
        }
    }

    static func dismantleUIView(_ uiView: ShinyView, coordinator: ()) {
        uiView.stopUpdates()
    }
}
