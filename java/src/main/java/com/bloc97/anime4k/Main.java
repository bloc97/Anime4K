/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.bloc97.anime4k;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

/**
 *
 * @author bloc97
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    static ImageKernel kernel = new ImageKernel();
    
    public static void main(String[] args) throws IOException {
        
        if (args.length < 2) {
            System.out.println("Error: Please specify input and output png files.");
            return;
        }
        
        String inputFile = args[0];
        String outputFile = args[1];
        
        BufferedImage img = ImageIO.read(new File(inputFile));
        img = copyType(img);
        
        float scale = 2f;
        
        if (args.length >= 3) {
            scale = Float.parseFloat(args[2]);
        }
        
        float pushStrength = scale / 6f;
        float pushGradStrength = scale / 2f;
        
        if (args.length >= 4) {
            pushGradStrength = Float.parseFloat(args[3]);
        }
        if (args.length >= 5) {
            pushStrength = Float.parseFloat(args[4]);
        }
                
        img = scale(img, (int)(img.getWidth() * scale), (int)(img.getHeight() * scale));
        
        kernel.setPushStrength(pushStrength);
        kernel.setPushGradStrength(pushGradStrength);
        kernel.setBufferedImage(img);
        kernel.process();
        kernel.updateBufferedImage();
        
        ImageIO.write(img, "png", new File(outputFile));
        
        
    }
    static BufferedImage copyType(BufferedImage bi) {
        BufferedImage newImage = new BufferedImage(bi.getWidth(), bi.getHeight(), BufferedImage.TYPE_INT_ARGB);
        newImage.getGraphics().drawImage(bi, 0, 0, null);
        return newImage;
    }
    static BufferedImage scale(BufferedImage bi, int width, int height) {
        BufferedImage newImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2 = (Graphics2D)newImage.getGraphics();
        g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g2.drawImage(bi, 0, 0, width, height, null);
        return newImage;
    }
    
}
