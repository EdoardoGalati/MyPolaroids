import SwiftUI

struct ColorWheelView: View {
    let gradient: FilmPackGradient?
    let size: CGFloat
    
    init(gradient: FilmPackGradient?, size: CGFloat = 32) {
        self.gradient = gradient
        self.size = size
    }
    
    var body: some View {
        if let gradient = gradient {
            // Gradiente personalizzato dal JSON
            if gradient.isElliptical {
                // Gradiente ellittico
                Circle()
                    .fill(
                        RadialGradient(
                            stops: gradient.stops.map { stop in
                                Gradient.Stop(
                                    color: Color(
                                        red: stop.color.red,
                                        green: stop.color.green,
                                        blue: stop.color.blue
                                    ),
                                    location: stop.location
                                )
                            },
                            center: UnitPoint(
                                x: gradient.center?.x ?? 0.5,
                                y: gradient.center?.y ?? 0.5
                            ),
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                    .frame(width: size, height: size)
            } else {
                // Gradiente lineare (default)
                Circle()
                    .fill(
                        LinearGradient(
                            stops: gradient.stops.map { stop in
                                Gradient.Stop(
                                    color: Color(
                                        red: stop.color.red,
                                        green: stop.color.green,
                                        blue: stop.color.blue
                                    ),
                                    location: stop.location
                                )
                            },
                            startPoint: UnitPoint(
                                x: gradient.startPoint?.x ?? 0.0,
                                y: gradient.startPoint?.y ?? 0.0
                            ),
                            endPoint: UnitPoint(
                                x: gradient.endPoint?.x ?? 1.0,
                                y: gradient.endPoint?.y ?? 1.0
                            )
                        )
                    )
                    .frame(width: size, height: size)
            }
        } else {
            // Fallback: cerchio bianco
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Diagrammi a torta con gradienti")
            .font(.title)
            .padding()
        
        HStack(spacing: 20) {
            Text("Film Color:")
            // Esempio di gradiente personalizzato
            let exampleGradient = FilmPackGradient(
                stops: [
                    GradientStop(color: RGBColor(red: 0.86, green: 0.29, blue: 0.21), location: 0.00),
                    GradientStop(color: RGBColor(red: 0.94, green: 0.54, blue: 0.2), location: 0.22),
                    GradientStop(color: RGBColor(red: 0.96, green: 0.72, blue: 0.25), location: 0.47),
                    GradientStop(color: RGBColor(red: 0.53, green: 0.74, blue: 0.25), location: 0.73),
                    GradientStop(color: RGBColor(red: 0.26, green: 0.54, blue: 0.83), location: 1.00)
                ],
                type: nil,
                startPoint: GradientPoint(x: 0.2, y: 0.85),
                endPoint: GradientPoint(x: 0.9, y: 0.25),
                center: nil
            )
            ColorWheelView(gradient: exampleGradient, size: 40)
        }
        
        HStack(spacing: 20) {
            Text("Fallback (bianco):")
            ColorWheelView(gradient: nil, size: 40)
        }
    }
    .padding()
}
