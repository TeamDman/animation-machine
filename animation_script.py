from manim import *
import yaml
from manim import config  # Import config to access frame dimensions

def load_animation_config(file_path):
    with open(file_path, 'r') as file:
        config_data = yaml.safe_load(file)
    return config_data

class CustomAnimation(Scene):
    def construct(self):
        # Load the configuration
        config_data = load_animation_config('animation.yaml')

        # Set up the background
        background_config = config_data['animation'].get('background', {})
        bg_color = background_config.get('color', WHITE)
        self.camera.background_color = bg_color

        # Create a vignette effect if specified
        if background_config.get('vignette', False):
            vignette = self.create_vignette()
            self.add(vignette)

        objects = []
        for obj_config in config_data['animation']['objects']:
            # Create objects based on their type
            if obj_config['type'] == 'circle':
                obj_color = obj_config['color']  # Use color string directly
                radius = obj_config.get('radius', 1)  # Get radius, default to 1
                circle = Circle(radius=radius, color=obj_color, fill_opacity=1)
                circle.id = obj_config['id']
                # Set initial position
                x = obj_config['position']['x']
                y = obj_config['position']['y']
                circle.move_to([x, y, 0])
                objects.append((circle, obj_config))

        # Add all objects to the scene
        for obj, _ in objects:
            self.add(obj)

        # Prepare animations
        animations = []
        for obj, obj_config in objects:
            # Movement
            to_x = obj_config['movement']['to_x']
            easing_function = self.get_easing_function(obj_config['movement']['easing'])
            animation = obj.animate.move_to([to_x, obj.get_center()[1], 0]).set_run_time(config_data['animation']['duration']).set_rate_func(easing_function)
            animations.append(animation)

        # Play animations
        self.play(*animations)

    def get_easing_function(self, easing_name):
        # Map easing function names to Manim rate functions
        easing_functions = {
            'linear': linear,
            'smooth': smooth,
            'rush_into': rush_into,
            'rush_from': rush_from,
            'slow_into': slow_into,
            'double_smooth': double_smooth,
            'there_and_back': there_and_back,
            'there_and_back_with_pause': there_and_back_with_pause,
        }
        return easing_functions.get(easing_name, linear)

    def create_vignette(self):
        # Create a vignette effect
        vignette = VGroup()
        vignette.add(Rectangle(
            width=config.frame_width,
            height=config.frame_height
        ).set_fill(BLACK, opacity=0.5).set_stroke(width=0))
        return vignette
