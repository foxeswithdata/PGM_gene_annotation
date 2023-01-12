import ai.djl.*;
import ai.djl.inference.Predictor;
import ai.djl.modality.Classifications;
import ai.djl.modality.cv.Image;
import ai.djl.modality.cv.ImageFactory;
import ai.djl.modality.cv.util.NDImageUtils;
import ai.djl.ndarray.NDArray;
import ai.djl.ndarray.NDList;
import ai.djl.nn.*;
import ai.djl.nn.core.*;

import java.io.*;
import java.nio.file.*;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import ai.djl.basicdataset.cv.classification.Mnist;
import ai.djl.ndarray.types.*;
import ai.djl.training.*;
import ai.djl.training.loss.*;
import ai.djl.training.listener.*;
import ai.djl.training.evaluator.*;
import ai.djl.training.util.*;
import ai.djl.translate.Batchifier;
import ai.djl.translate.TranslateException;
import ai.djl.translate.Translator;
import ai.djl.translate.TranslatorContext;
import processing.core.PApplet;

public class main extends PApplet {
    static int epochs = 2;

    private static final Translator<Image, Classifications> translator = new Translator<Image, Classifications>() {

        @Override
        public NDList processInput(TranslatorContext ctx, Image input) {
            // Convert Image to NDArray
            NDArray array = input.toNDArray(ctx.getNDManager(), Image.Flag.GRAYSCALE);
            return new NDList(NDImageUtils.toTensor(array));
        }

        @Override
        public Classifications processOutput(TranslatorContext ctx, NDList list) {
            // Create a Classifications with the output probabilities
            NDArray probabilities = list.singletonOrThrow().softmax(0);
            List<String> classNames = IntStream.range(0, 10).mapToObj(String::valueOf).collect(Collectors.toList());
            return new Classifications(classNames, probabilities);
        }

        @Override
        public Batchifier getBatchifier() {
            // The Batchifier describes how to combine a batch together
            // Stacking, the most common batchifier, takes N [X1, X2, ...] arrays to a single [N, X1, X2, ...] array
            return Batchifier.STACK;
        }
    };

    public static void main(String[] args) {
        try {
            runApp();
        } catch (IOException | TranslateException e) {
            e.printStackTrace();
        }
    }

    private static void runApp() throws IOException, TranslateException {
        //Application application = Application.CV.IMAGE_CLASSIFICATION;
        System.out.println("What would you like to do?\n1) Train a model\n2) Load and test an existing model");
        Scanner scanner = new Scanner(System.in);
        int choice = scanner.nextInt();
        if (choice == 1) {
            SequentialBlock network = buildNetwork();
            Model model = trainNetwork(network);
            saveModel(model, "models/test");
        } else if (choice == 2) {
            Model model = loadModel("models/test");
            PApplet.main("main");
            predictInput(model);
        } else {
            System.out.println("Invalid choice, please try again");
            runApp();
        }
    }

    public void settings() {
        size(28, 28);
    }

    public void setup() {
        background(255);
    }

    public void draw() {
        strokeWeight(2);
        stroke(0);
        if (mousePressed) {
            line(mouseX, mouseY, pmouseX, pmouseY);
        }
    }



    private static SequentialBlock buildNetwork(){
        long inputSize = 28*28; // 28x28 pixels
        long outputSize = 10; // numbers 0-9
        SequentialBlock block = new SequentialBlock();

        //input layer
        block.add(Blocks.batchFlattenBlock(inputSize));

        //hidden layers
        block.add(Linear.builder().setUnits(128).build()); // neuron layer 1
        block.add(Activation::relu); // weights layer 1 -> layer 2
        block.add(Linear.builder().setUnits(64).build()); // neuron layer 2
        block.add(Activation::relu); // weights layer 2 -> output layer

        //output layer
        block.add(Linear.builder().setUnits(outputSize).build());
        return block;
    }

    private static Model trainNetwork(SequentialBlock network) throws IOException, TranslateException {
        int batchSize = 32;
        Mnist mnist = Mnist.builder().setSampling(batchSize, true).build();
        mnist.prepare(new ProgressBar());

        Model model = Model.newInstance("mlp");
        model.setBlock(network);

        DefaultTrainingConfig config =
                new DefaultTrainingConfig(Loss.softmaxCrossEntropyLoss())
                        .addEvaluator(new Accuracy())
                        .addTrainingListeners(TrainingListener.Defaults.logging());
        Trainer trainer = model.newTrainer(config);

        trainer.initialize(new Shape(1, 28 * 28));


        EasyTrain.fit(trainer,epochs,mnist,null);

        return model;
    }

    private static void saveModel(Model model, String path){
        model.setProperty("Epoch", String.valueOf(epochs));
        Path modelDir = Paths.get(path);
        try {
            Files.createDirectories(modelDir);
            model.save(modelDir, "mlpTest");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static Model loadModel(String path){
        Path modelDir = Paths.get(path);
        Model model = Model.newInstance("mlp");
        model.setBlock(buildNetwork());
        try {
            model.load(modelDir);
        } catch (IOException | MalformedModelException e) {
            e.printStackTrace();
        }
        return model;
    }

    private static void predictInput(Model model){
        Predictor<Image, Classifications> predictor = model.newPredictor(translator);
        Image image = null;
        try {
            image = ImageFactory.getInstance().fromFile(Paths.get("img.png"));
            //image.getWrappedImage();
        } catch (IOException e) {
            e.printStackTrace();
        }
        if(image != null) {
            try {
                Classifications classifications = predictor.predict(image);
            } catch (TranslateException e) {
                e.printStackTrace();
            }
        }
    }



}
