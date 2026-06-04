extends Node
class_name DialogueDatabase

## The "Soul" of the game: A massive collection of absurd dialogue.

var corporate_buzzwords = [
	"I truly value your feedback and will escalate this to our regional synergy coordinator.",
	"We are currently optimizing our guest-centric paradigms to better serve your needs.",
	"I apologize for the friction in your experience; let me apply a solution-oriented approach.",
	"Your satisfaction is our primary KPI, and I am committed to a holistic resolution.",
	"I understand your frustration and would like to offer you a complimentary 'Smile-Sized' fry.",
	"We are pivoting our service model to ensure a more seamless interaction for you."
]

var savage_comebacks = [
	"Sir, this is a drive-thru, not a therapy session. Please move your car.",
	"I'm sorry, I can't hear you over the sound of me not caring about your coupon.",
	"I would love to help you, but I'm currently on my mandated 30-second existential crisis break.",
	"The burger is exactly how it's supposed to be. Your taste buds are the problem here.",
	"I've had three mental breakdowns today; your missing napkin is the least of my concerns.",
	"I'm not paid enough to argue with someone who orders a burger with no bun, no meat, and no condiments."
]

var corporate_memos = [
	"Effective immediately, employees must refer to the fryer as 'The Golden Sizzler' to increase morale.",
	"We have noticed a decrease in 'Eye-Contact Efficiency.' Please stare at customers 15% longer.",
	"Reminder: The break room is for resting, not for discussing the futility of our existence.",
	"New Policy: If a customer screams, you are encouraged to scream back, but only in a 'Professional Tone'.",
	"Corporate is testing a new 'Scent-Based Upsell.' Please spray 'Fresh-Burger' perfume on your uniforms.",
	"The regional manager is visiting. Please hide all the 'non-standard' sauce bottles immediately."
]

var firing_reasons = [
	"Repeated sauce negligence leading to a 'Dry-Bun Crisis'.",
	"Failure to maintain a 'Corporate-Approved' smile during a rush.",
	"Accepting payment in 'Good Vibes' and 'Exposure'.",
	"Allowing the fryer to become the de facto Shift Lead.",
	"Accidentally bagging a stapler instead of a burger.",
	"Spending 45 minutes staring at a single nugget in contemplation."
]

func get_random_buzzword(): return corporate_buzzwords.pick_random()
func get_random_comeback(): return savage_comebacks.pick_random()
func get_random_memo(): return corporate_memos.pick_random()
func get_random_firing_reason(): return firing_reasons.pick_random()
