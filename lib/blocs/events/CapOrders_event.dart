abstract class CapOrdersEvents  {}


class CapOrdersCurrent extends CapOrdersEvents {}
class CapOrdersReserved extends CapOrdersEvents {}
class CapOrdersPickedUp extends CapOrdersEvents {}
class GenerateError extends CapOrdersEvents{}
