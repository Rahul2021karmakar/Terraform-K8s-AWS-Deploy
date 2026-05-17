module "vpc" {
  source            = "../../modules/vpc"
  vpc_cidr          = var.vpc_cidr
  project           = var.project
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
}

module "iam" {
  source      = "../../modules/iam"
  project     = var.project
}


module "eks" {
  source              = "../../modules/eks"
  depends_on          = [ module.vpc]
  project             = var.project
  tags                = var.tags
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = flatten([module.vpc.public_subnet_ids, module.vpc.private_subnet_ids])
  private_subnet_ids  = module.vpc.private_subnet_ids
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_role_arn       = module.iam.eks_node_role_arn
}

module "oidc" {
  source          = "../../modules/oidc"
  depends_on = [ module.eks ]
  cluster_name    = module.eks.cluster_name
}

module "addons" {
  source              = "../../modules/addons"
  depends_on          = [ module.eks ]
  cluster_name        = module.eks.cluster_name
  oidc_provider_url   = module.oidc.oidc_provider_url
  oidc_provider_arn   = module.oidc.oidc_provider_arn
}
