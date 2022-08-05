# @summary Supported NServicebus transports
type Nservicebusservicecontrol::Transport = Enum['RabbitMQ - Conventional routing topology', 'RabbitMQ - Conventional routing topology (classic queues)', 'RabbitMQ - Conventional routing topology (quorum queues)', 'SQL Server', 'MSMQ', 'Azure Storage Queue', 'Azure Service Bus', 'AmazonSQS']
