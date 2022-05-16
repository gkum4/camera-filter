//
//  CameraFilterHandler.swift
//  CameraFilter
//
//  Created by Gustavo Kumasawa on 16/05/22.
//

import CoreImage.CIFilterBuiltins
import UIKit

class CameraFilterHandler {
    var filtersToApply: [Filters] = []
    
    func applyFilter(image: CIImage) -> CIImage {
        var finalImage = image
        
        for filter in filtersToApply {
            switch filter {
            case .sepiaTone:
                finalImage = applySepiaToneFilter(to: finalImage)
            case .darkScratches:
                finalImage = applyDarkScratchesFilter(to: finalImage)
            case .whiteSpecks:
                finalImage = applyWhiteSpecksFilter(to: finalImage)
            case .colorInvert:
                finalImage = applyColorInvertFilter(to: finalImage)
            case .redIncrease:
                finalImage = applyRedIncreaseFilter(to: finalImage)
            case .bloom:
                finalImage = applyBloomFilter(to: finalImage)
            case .noir:
                finalImage = applyNoirFilter(to: finalImage)
            case .blink:
                finalImage = applyBlinkFilter(to: finalImage)
            case .colorGlitch:
                finalImage = applyColorGlitchFilter(to: finalImage)
            }
        }
        
        return finalImage
    }
    
    enum Filters: String {
        case sepiaTone = "Sepia Tone"
        case darkScratches = "Dark Scratches"
        case whiteSpecks = "White Specks"
        case colorInvert = "Color Invert"
        case redIncrease = "Red Increase"
        case bloom = "Bloom"
        case noir = "Noir"
        case blink = "Blink"
        case colorGlitch = "Color Glitch"
    }
    
    private func applySepiaToneFilter(to image: CIImage) -> CIImage {
        let filter = CIFilter.sepiaTone()
        filter.intensity = 0.8
        filter.inputImage = image
        
        guard let outputImage = filter.outputImage else {
            print("Error applying SepiaToneFilter")
            return CIImage()
        }
        
        return outputImage
    }
    
    private func applyDarkScratchesFilter(to image: CIImage) -> CIImage {
        let noiseImage = getNoiseImage()
        let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        
        let verticalScale = CGAffineTransform(scaleX: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 20...25))
        let transformedNoise = noiseImage.transformed(by: verticalScale)
        
        let darkenVector = CIVector(x: CGFloat.random(in: 2...4), y: 0, z: 0, w: 0)
        let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
        
        let darkeningFilter = CIFilter.colorMatrix()
        darkeningFilter.inputImage = transformedNoise
        darkeningFilter.rVector = darkenVector
        darkeningFilter.gVector = zeroVector
        darkeningFilter.bVector = zeroVector
        darkeningFilter.aVector = zeroVector
        darkeningFilter.biasVector = darkenBias
        
        guard let randomScratches = darkeningFilter.outputImage else {
            print("Error generating randomScratches")
            return CIImage()
        }
        
        let grayscaleFilter = CIFilter.minimumComponent()
        grayscaleFilter.inputImage = randomScratches
        
        guard let darkScratches = grayscaleFilter.outputImage else {
            print("Error generating darkScratches")
            return CIImage()
        }
        
        let oldFilmCompositor = CIFilter.multiplyCompositing()
        oldFilmCompositor.inputImage = darkScratches
        oldFilmCompositor.backgroundImage = image
        
        guard let oldFilmImage = oldFilmCompositor.outputImage else {
            print("Error genearting oldFilmImage")
            return CIImage()
        }
        
        let finalImage = oldFilmImage.cropped(to: image.extent)
        
        return finalImage
    }
    
    private func applyWhiteSpecksFilter(to image: CIImage) -> CIImage {
        let noiseImage = getNoiseImage()
        
        let whitenVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        let fineGrain = CIVector(x:0, y: 0.005, z: 0, w: 0)
        let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        
        let whiteningFilter = CIFilter.colorMatrix()
        whiteningFilter.inputImage = noiseImage
        whiteningFilter.rVector = whitenVector
        whiteningFilter.gVector = whitenVector
        whiteningFilter.bVector = whitenVector
        whiteningFilter.aVector = fineGrain
        whiteningFilter.biasVector = zeroVector
        
        guard let whiteSpecks = whiteningFilter.outputImage else {
            print("Error generating white specs")
            return CIImage()
        }
        
        let speckCompositor = CIFilter.sourceOverCompositing()
        speckCompositor.inputImage = whiteSpecks
        speckCompositor.backgroundImage = image

        guard let speckledImage = speckCompositor.outputImage else {
            print("Error generating whiteSpecks")
            return CIImage()
        }
        
        let finalImage = speckledImage.cropped(to: image.extent)
        
        return finalImage
    }
    
    private func applyColorInvertFilter(to image: CIImage) -> CIImage {
        let colorInvertFilter = CIFilter.colorInvert()
        colorInvertFilter.inputImage = image
        
        guard let colorInvertedImage = colorInvertFilter.outputImage else {
            print("Error generating colorInvertImage")
            return CIImage()
        }
        
        return colorInvertedImage
    }
    
    private func applyRedIncreaseFilter(to image: CIImage) -> CIImage {
        let colorClampFilter = CIFilter.colorClamp()
        colorClampFilter.inputImage = image
        colorClampFilter.minComponents = CIVector(x: 0, y: 0, z: 0, w: 0)
        colorClampFilter.maxComponents = CIVector(x: 1, y: 0.3, z: 0.3, w: 1)

        guard let colorClampedImage = colorClampFilter.outputImage else {
            print("Error generating colorClampedImage")
            return CIImage()
        }

        return colorClampedImage
    }
    
    private func applyBloomFilter(to image: CIImage) -> CIImage {
        let bloomFilter = CIFilter.bloom()
        bloomFilter.inputImage = image
        bloomFilter.intensity = 0.8
        
        guard let bloomedImage = bloomFilter.outputImage else {
            print("Error generating bloomedImage")
            return CIImage()
        }
        
        return bloomedImage
    }
    
    private func applyNoirFilter(to image: CIImage) -> CIImage {
        let noirFilter = CIFilter.photoEffectNoir()
        noirFilter.inputImage = image
        
        guard let noiredImage = noirFilter.outputImage else {
            print("Error generating bloomedImage")
            return CIImage()
        }
        
        return noiredImage
    }
    
    private func applyBlinkFilter(to image: CIImage) -> CIImage {
        let blinkFilter = CIFilter.colorClamp()
        blinkFilter.inputImage = image
        blinkFilter.minComponents = CIVector(x: 0, y: 0, z: 0, w: 0)
        blinkFilter.maxComponents = CIVector(x: 1, y: 1, z: 1, w: CGFloat.random(in: 0...0.5))

        guard let blinkedImage = blinkFilter.outputImage else {
            print("Error generating blinkedImage")
            return CIImage()
        }
        
        return blinkedImage
    }
    
    private func applyColorGlitchFilter(to image: CIImage) -> CIImage {
//        let colorGlitchFilter = CIFilter.colorClamp()
//        colorGlitchFilter.inputImage = image
//        colorGlitchFilter.minComponents = CIVector(x: 0, y: 0, z: 0, w: 0)
//        colorGlitchFilter.maxComponents = CIVector(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1), z: CGFloat.random(in: 0...1), w: CGFloat.random(in: 0...1))
//
//        guard let colorGlitchedImage = colorGlitchFilter.outputImage else {
//            print("Error generating colorGlitchedImage")
//            return CIImage()
//        }
//
//        return colorGlitchedImage
        
        let colorGlitchFilter = CIFilter.colorClamp()
        colorGlitchFilter.inputImage = image
        colorGlitchFilter.minComponents = CIVector(x: 0, y: 0, z: 0, w: 0)
        colorGlitchFilter.maxComponents = CIVector(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            z: CGFloat.random(in: 0...1),
            w: CGFloat.random(in: 0...1)
        )
        guard let colorGlitchedImage1 = colorGlitchFilter.outputImage else {
            print("Error generating colorGlitchedImage1")
            return CIImage()
        }
        
        colorGlitchFilter.minComponents = CIVector(x: 0, y: 0, z: 0, w: 0)
        colorGlitchFilter.maxComponents = CIVector(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            z: CGFloat.random(in: 0...1),
            w: CGFloat.random(in: 0...1)
        )
        guard let colorGlitchedImage2 = colorGlitchFilter.outputImage else {
            print("Error generating colorGlitchedImage2")
            return CIImage()
        }
        
        return CIImage() // TODO: Juntar glitches
        
    }
    
    private func getNoiseImage() -> CIImage {
        let noiseFilter = CIFilter.randomGenerator()
        guard let noiseImage = noiseFilter.outputImage else {
            print("Error generating noiseImage")
            return CIImage()
        }
        
        return noiseImage
    }
}
