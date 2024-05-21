module "vpc" {
  source                = "./modules/VPC"
  name                  = var.name
  vpc_cidr              = var.vpc_cidr
  region                = var.region
  public_subnet_config  = var.public_subnet_config
}


/****************************
          EKS Cluster
*****************************/
data "aws_iam_policy_document" "eks-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks" {
  name               = "eks-cluster-example"
  assume_role_policy = data.aws_iam_policy_document.eks-role.json
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = "h-eks_cluster"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnet_ids[*]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy]
}

/****************************
        EKS Node Group
*****************************/
data "aws_iam_policy_document" "nodeGroup-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "nodeGroup-role" {
    name = "h-nodeGroup-role"
    assume_role_policy = data.aws_iam_policy_document.nodeGroup-role.json
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodeGroup-role.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodeGroup-role.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodeGroup-role.name
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "nodes"
  node_role_arn   = aws_iam_role.nodeGroup-role.arn
  subnet_ids = module.vpc.public_subnet_ids[*]
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }


  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}
